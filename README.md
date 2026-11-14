# landtalks.org

The Land Talks website. It's built by `build.py`, which needs only Python: no
Ruby, Jekyll or anything to install.

## How it works

You edit the files here and push to `main`. A GitHub Action
(`.github/workflows/publish.yml`) then runs `build.py` and publishes the result
to GitHub Pages, usually within a minute or two. **Every push to `main` goes
live.** You can follow each run in the repo's Actions tab, and a failed build
leaves the live site as it was.

GitHub's Settings > Pages > Source must be set to "GitHub Actions".

`build.py` turns the files below into a finished site in `_site/`, which git
ignores:

| Where | What |
|---|---|
| `_talks/<evening>/<name>.md` | One talk: its text and details |
| `slides/<evening>/<name>.pdf` | That talk's slides |
| `_data/evenings.yml` | Each evening's number, month and Luma link |
| `index.html` | The home page |
| `talks/index.html` | The Talks page |
| `_layouts/`, `_includes/` | Templates: shared page parts, talk page, home page card |
| `style.css`, `images/` | Styles and pictures |
| `assets/emoji/` | A picture of each emoji in use |
| `assets/flip.js` | The slide viewer |
| `assets/pdfjs/` | PDF.js, which the viewer uses to draw PDFs in the browser |

## Test locally

Try changes here before pushing:

```bash
./preview-locally.command      # or double-click it in Finder
```

It builds the site, opens <http://localhost:47213/> in Firefox, and serves until
you close the window or press Ctrl-C (underneath, it's `python3 build.py
--serve`). After editing anything, stop it and run it again. If something is wrong with a file, the build says which one.

## Add a talk

1. Create `_talks/<evening>/<name>.md`, for example `_talks/8/beth.md`:

   ```markdown
   ---
   title: "The talk's title"
   speaker: "Beth Example"
   evening: 8
   emoji: 🌱
   hook: "One opening sentence."
   ---

   The rest of the description.
   ```

2. Put the slides at `slides/<evening>/<name>.pdf`, for example
   `slides/8/beth.pdf`. Until the PDF is there, the page has no slides or
   download link (or a countdown, before the evening: see below).

3. For a new evening, also add it to the top of `_data/evenings.yml`.

4. Test it, then push.

That one file feeds the talk's page at `/talks/8/beth/`, the home page's random
cards and the Talks page. The filename sets the web address, so don't rename a
talk once it's live. Talks within an evening are listed alphabetically by
filename.

Optional fields: `bio`, `photo` (a file in `images/speakers/`), `action_text`
and `action_url`.

## A new evening, before and after

The talks can go up before the evening, as soon as they're on Luma, without
their slides. Where the slides will go, each talk page then shows a dashed
frame saying *"The slides will be here after the talk on Tuesday 17
November."*, a countdown to the start, and a "See the talk yourself" link to
the evening's Luma page.

**Before the evening:**

1. Add the evening to the top of `_data/evenings.yml` with two extra fields:

   ```yaml
   - number: 8
     when: Nov 2026
     url: https://lu.ma/0xftehgg
     day: Tuesday 17 November
     starts: 2026-11-17T18:30:00Z
   ```

   `day` is the date as the page writes it. `starts` is when the talks begin,
   in UTC (the `Z`): the same as London time in winter, but an hour earlier
   in British Summer Time, so a summer 6.30pm is `17:30:00Z`. `url` is the
   Luma page, which is where "See the talk yourself" goes.

2. Add a file in `_talks/<evening>/` for each talk, from the Luma copy (see
   "Add a talk" above), with no PDFs.

3. Test it and push.

**On the day:** at the start time the countdown and the link go, and the frame
says *"The talks are on now. The slides will be here afterwards."* The site is
only rebuilt when you push, so it keeps saying that, even days later, until
the slides are added. Add them soon after the evening.

**After the evening:**

1. Put each speaker's final PDF at `slides/<evening>/<name>.pdf`. Each talk
   whose PDF is there shows the slide viewer and download link instead of the
   frame.
2. Take `day` and `starts` out of the evening in `_data/evenings.yml`. With
   them gone, a talk that never gets slides just has no frame, rather than
   saying the talks are on now.
3. Test it and push.

The build's last line, "No PDF yet for: ...", lists the talks still waiting
for slides.

The countdown is a permanent part of the site, used for every evening. It is
turned on and off only by `day` and `starts` in `_data/evenings.yml`. Never
delete its code, in `_layouts/talk.html` (the `soon` block and its script)
and `style.css` (the `.soon` rules), when an evening is over.

## Emoji

Emoji are pictures of Noto's artwork, not text, because browsers draw text emoji
at different sizes and in different styles. Noto is also the style on the house
slides. You still just type the emoji in a talk's file.

The first time an emoji is used, the build downloads its picture from
<https://github.com/googlefonts/noto-emoji> into `assets/emoji/`, so commit that
file too. Most are Apache-licensed, and the flags are public domain.

The same picture is sized differently in each place, in `style.css`:

| Where | How | Why |
|---|---|---|
| Talk page headline (`.talk-h1 .talk-emoji`) | Its own width, sized to the capitals | Sits next to the first letter with an even gap, like a letter |
| Talks page (`.talks-index__group li .talk-emoji`) | Centred in a fixed-width column | Keeps the titles and speakers in a straight line |
| Home page cards (`.talk__emoji img`) | Its own width, on its own line | Nothing to line up with |

The even gap in headlines depends on each picture being cropped to its artwork's
width, because Noto draws them all on a square canvas. A newly downloaded picture
keeps its blank sides until `trim_emoji.js` has been run on it. That needs
Playwright; instructions are at the top of the file. Re-running it is safe.

## Changing templates

Templates use `{{ page.title }}` and `{% if %}`, from the Liquid template
language. `build.py` understands only the parts of Liquid the site uses, and
stops with an error on anything else, so a new template feature may need a few
lines added to it.
