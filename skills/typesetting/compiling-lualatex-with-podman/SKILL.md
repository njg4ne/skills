---
name: compiling-lualatex-with-podman
description: Scaffolds, builds, and checks LuaLaTeX documents to PDF inside Podman (or Docker) containers, with the user's chosen fonts, size, line spacing, paper, margins, bibliography style, SVG figures, tagged accessible PDF output, highlighted code listings, and embedded file attachments. Works on macOS, Linux, and Windows because every tool runs in a container. Use when the user wants a PDF typeset with LaTeX/LuaLaTeX, a reproducible containerized TeX setup, custom fonts via fontspec, an accessible or tagged PDF, code or attachments in a PDF, or mentions latexmk, biber, or compiling a .tex file without installing TeX locally.
license: MIT
compatibility: Requires Podman (preferred) or Docker, plus a POSIX shell (scripts/latex.sh) or PowerShell 5.1+ (scripts/latex.ps1). All TeX, PDF, and validation tools run in containers. The first build pulls the full TeX Live image (several GB); veraPDF validation pulls its own image.
metadata:
  author: Nicholas Gardella
  version: "2.0"
---

# Compiling LuaLaTeX with Podman

Run the launcher for every mechanical step. Do not hand-write the Containerfile,
latexmkrc, preamble, or build commands, and do not run TeX, PDF, or text-processing
tools on the host: the launcher starts containers that do the work deterministically.
Spend your effort on the document's content. Edit files with your editor tools.

## How commands run

One host launcher per platform; both take the same commands:

```sh
scripts/latex.sh  COMMAND PROJECT_DIR [ARGS]      # macOS, Linux
```
```powershell
scripts\latex.ps1 COMMAND PROJECT_DIR [ARGS]      # Windows PowerShell
```

Call it by its path inside this skill's directory, from any working directory; the
project path is resolved against the current directory. Examples below use the `sh`
form; on Windows replace `scripts/latex.sh` with `scripts\latex.ps1`. Set the
environment variable `ENGINE=docker` to use Docker.

The launcher only runs `podman build` and `podman run`. The project carries its own
build tool (`tools/latexctl`), which runs inside the project's image, so a scaffolded
project builds without this skill installed.

## Workflow

Copy this checklist and tick it off:

```
- [ ] 1. Settings collected (ask, or use defaults if told not to ask)
- [ ] 2. Engine works: `podman info` (or `docker info`) succeeds
- [ ] 3. latex.sh scaffold run with the settings
- [ ] 4. Content written in src/ (SVG figures in src/figures/)
- [ ] 5. latex.sh build passes
- [ ] 6. Log warnings fixed, rebuilt until clean
- [ ] 7. Pages rendered and inspected (if you can view images)
- [ ] 8. latex.sh check-pdf passes; latex.sh verapdf when accessibility matters
```

### 1. Collect settings

These settings change the output. If the user has not stated one, **ask them,
in one batch of questions, before scaffolding**. If the user said not to stop
for questions, or you run non-interactively, use the defaults and list every
default you applied in your final report.

| Setting | Flag | Default |
|---|---|---|
| Project directory | `PROJECT_DIR` argument | (always ask if unclear) |
| Body / sans / mono font | `--main-font` `--sans-font` `--mono-font` | Latin Modern Roman / Sans / Mono |
| Font size | `--size` (8–20) | 11 |
| Line spacing | `--spacing` single, onehalf, double | single |
| Paper | `--paper` letter, a4, legal, a5, b5 | letter |
| Margins | `--margin` (1in, 2.5cm) | 1in |
| Document class | `--class` article, report, book | article |
| Bibliography | `--bib` none, numeric, authoryear, apa, ieee | numeric |
| Title, author | `--title` `--author` | Untitled, empty |
| Tagged (accessible) PDF | `--tagged` yes, no | yes |
| PDF language | `--lang` (BCP 47 tag) | en-US |

Translate plain requests with [references/formatting.md](references/formatting.md)
(for example, "normal margins" means 1in on letter paper). Look up every requested font
in [references/fonts.md](references/fonts.md): many OpenType fonts are already in TeX
Live, and `--font-packages` is needed only for fonts outside it. Prefer OpenType fonts;
a TrueType font rules out a PDF/UA claim, so tell the user and offer the OpenType
equivalent listed there.

### 2. Check the engine

Run `podman info` (or `docker info`). On macOS and Windows, if it cannot connect,
the Podman machine is stopped: `podman machine start`. Relay any other failure to the
user; do not install software without their consent.

### 3. Scaffold

```sh
scripts/latex.sh scaffold ./report --main-font "TeX Gyre Heros" \
  --sans-font "TeX Gyre Heros" --mono-font "Source Code Pro" \
  --size 12 --spacing onehalf --paper letter --margin 1in \
  --bib numeric --title "My Report" --author "A. Author"
```

The scaffold runs in a small pinned container and creates, without overwriting
existing files (add `--force` to replace):

```
report/
├── Containerfile        build image: pinned TeX Live base, extra font packages
├── .containerignore     empty build context, so rebuilds stay fast
├── latex-build.env      MAIN_TEX, REQUIRED_FONTS, TAGGED
├── tools/latexctl       build tool; runs inside the image
├── .gitignore
└── src/
    ├── .latexmkrc       lualatex, biber, nonstop, halt on error
    ├── manuscript.tex   preamble with the chosen settings
    ├── refs.bib         (unless --bib none)
    └── figures/
```

Add `--compose` only if the user wants a `compose.yml`; the launcher does not need it.

To change fonts later, edit the font lines in the preamble and `REQUIRED_FONTS` in
`latex-build.env`; for a font outside TeX Live, also append its Debian package to the
`apt-get install` line in the Containerfile. Re-scaffolding with `--force` overwrites
`manuscript.tex`, so never use it once content exists.

### 4. Write content

**Existing `.tex` file.** Scaffold first, then copy the user's file and any assets it
needs into `src/`, and set `MAIN_TEX` in `latex-build.env` to its name. Keep the
user's preamble, but for tagged output add the `\DocumentMetadata` line from the
generated `manuscript.tex` as its first line, and replace tagging-unsafe packages
yourself: delete `\usepackage{titlesec}` and its `\titleformat` lines, and delete
`\usepackage{listings}`, converting each `lstlisting` or `\lstinputlisting` to the
snippet's `\codefile` or `\taggedcode` (see accessibility.md). If the user needs those
packages unchanged, produce an untagged PDF instead: leave out `\DocumentMetadata` and
set `TAGGED='no'` in `latex-build.env`.

**New content.** Edit `src/manuscript.tex`. Put figures in `src/figures/` as SVG and
include them by base name (`\includegraphics{diagram}`); the build converts each SVG
to PDF. Give SVG text an installed `font-family`, or it renders in a fallback font.
Give every figure alternative text (`alt` key). For code listings and attached files,
copy `assets/snippets/code-and-attachments.tex` into `src/`, `\input` it in the
preamble, and use its `\codefile` command; details in
[references/code-and-attachments.md](references/code-and-attachments.md). Files may
live anywhere inside the project directory (reference them as `../dir/file` from
`src/`); the build mounts the whole project, nothing outside it.

### 5. Build

```sh
scripts/latex.sh build ./report          # add --clean to force a full rebuild
```

Rebuilds the image (cached after the first run, which pulls TeX Live and takes a
while; log in `build/image-build.log`), verifies that every requested font exists,
converts SVGs, runs latexmk, then checks the log. Output: `report/src/manuscript.pdf`,
copied to `report/build/output.pdf`.

### 6. Fix and rebuild

The build ends with a log check that prints errors, missing glyphs, undefined
references, overfull lines of 1pt or more, and tagging warnings. Fix each, rebuild,
and repeat until it reports `clean`. `scripts/latex.sh check-log ./report` repeats the
check. Fixes for common messages are in
[references/troubleshooting.md](references/troubleshooting.md).

### 7. Inspect visually

```sh
scripts/latex.sh render ./report 1 3            # pages 1-3; omit numbers for all pages
scripts/latex.sh render ./report 2 --dpi 150    # one page in detail
```

Writes `report/build/pages/page-N.png` at 60 dpi by default. If you can view images,
check figures, tables, and the title page. Text extraction does not reveal layout
problems.

### 8. Check the PDF

```sh
scripts/latex.sh check-pdf ./report     # metadata, tagging, fonts, bookmarks, attachments
scripts/latex.sh verapdf ./report       # PDF/UA-2 validation (slow on arm64); ua1 also accepted
```

Fix errors `check-pdf` reports. For `verapdf`, look up each failed rule in
[references/accessibility.md](references/accessibility.md) or
[references/troubleshooting.md](references/troubleshooting.md), fix all of them, then
rebuild and re-run, repeating until it reports `failedRules="0"`. Only then add
`pdfstandard=ua-2` to `\DocumentMetadata`, rebuild, and validate once more. Report any
rule you could not fix.

## Further reading

- Tagging, headings, bookmarks, cross-references, alt text, validation:
  [references/accessibility.md](references/accessibility.md)
- Highlighted code (piton) and file attachments (embedfile), viewer support:
  [references/code-and-attachments.md](references/code-and-attachments.md)

## Rules

- Run nothing on the host except the launcher and `podman`/`docker` themselves.
- Keep the base image pinned by digest in the Containerfile; change it only on purpose.
- Keep sources (`.tex`, `.bib`, `.svg`, `latex-build.env`, `Containerfile`, `tools/`)
  under version control. Build artifacts are git-ignored.
- Keep the preamble tagging-safe: no titlesec or listings; wrap piton listings as one
  P/Code block; attach files with embedfile and `afrelationship`. Give every figure
  `alt` text. Prefer OpenType fonts (also in SVG figures). Declare PDF/UA-2
  (`pdfstandard=ua-2`) only after `verapdf` reports no failed rules.
- Use the template's `\appsection` and `\unnumsec` for appendix and unnumbered
  headings, and `\autoref`/`\ref` with labels instead of hard-coded numbers.
- Report to the user: the PDF path, the settings used (marking defaults), and any
  remaining warnings with their cause.
