#!/bin/bash
#
# Land Talks website - build it and look at it on this machine before pushing.
#
# Double-click this file in Finder, or run ./preview-locally.command.
# It builds the site with build.py, opens it in Firefox at
# http://localhost:47213/, and serves it until you close this window or press
# Ctrl-C. After editing anything, close it and run it again.
#
# Nothing is committed and nothing is published. Every push to main goes live
# on landtalks.org, so try changes here first.

set -euo pipefail

# Finder runs a double-clicked .command from the home directory, not from here.
cd "$(dirname "$0")"

bold=$'\033[1m'; red=$'\033[31m'; off=$'\033[0m'

step()  { printf "\n%s==> %s%s\n" "$bold" "$1" "$off"; }
pause() { printf "\nPress any key to close this window. "; read -r -n 1 -s || true; printf "\n"; }
fail()  { trap - ERR; printf "\n%s%s%s\n" "$red$bold" "$1" "$off"; pause; exit 1; }
trap 'fail "Something went wrong above."' ERR

URL="http://localhost:47213/"

step "Checking"
command -v python3 >/dev/null || fail "python3 isn't installed. It builds the site."
if (exec 3<>/dev/tcp/127.0.0.1/47213) 2>/dev/null; then
    fail "Something is already serving on port 47213 - perhaps this, in another window. Close that first."
fi

# Open the browser once the server is answering, so the page doesn't load
# before there is anything there.
open_when_up() {
    for _ in $(seq 1 50); do
        if (exec 3<>/dev/tcp/127.0.0.1/47213) 2>/dev/null; then
            if [ "$(uname)" = Darwin ]; then
                open -a Firefox "$URL" 2>/dev/null || open "$URL"
            fi
            return
        fi
        sleep 0.2
    done
}

step "Building and serving at $URL (close this window or press Ctrl-C to stop)"
open_when_up &

# build.py stops with a message naming the file if something is wrong.
trap - ERR
status=0
python3 build.py --serve || status=$?
[ "$status" -eq 0 ] || [ "$status" -eq 130 ] || fail "build.py stopped with an error (above)."
pause
