# Troubleshooting

Messages come from the launcher (`latex.sh` / `latex.ps1`), the in-container build
(`tools/latexctl`), or veraPDF.

| Symptom | Cause | Fix |
|---|---|---|
| `font(s) not found in image` | Font outside TeX Live, or wrong family name | Check the name (fonts.md); for a font outside TeX Live, append its Debian package to the `apt-get install` line in the Containerfile |
| `image build failed` | Wrong Debian package name, or no network | Read `build/image-build.log`; look the package up on packages.debian.org (Debian testing) |
| Engine cannot connect (macOS, Windows) | Podman machine stopped | `podman machine start` |
| PowerShell: "running scripts is disabled on this system" | Execution policy blocks unsigned scripts | Run `powershell -ExecutionPolicy Bypass -File scripts\latex.ps1 build .\report`, or `Unblock-File scripts\latex.ps1` once |
| `Permission denied` writing in the project | Container UID cannot write the bind mount | The launchers pass `--userns=keep-id` (Podman) or `--user` (Docker on Linux); on SELinux hosts (Fedora/RHEL) add `:Z` to the `-v` mounts in the launcher |
| `MISSING GLYPHS` | Font lacks a character (e.g. →, ≥, emoji, CJK) | Choose a font with coverage, or add a fallback (`\newfontfamily` for that text, or luaotfload fallback lists) |
| `UNDEFINED REFERENCES/CITATIONS` after a successful build | Wrong label/key, or entry missing in refs.bib | Fix the key; latexmk reruns biber automatically |
| `OVERFULL LINES` | Long URL, path, or unbreakable word | Use `\url`/`\path` for URLs and paths, rephrase, or give table columns `X`/`p{}` widths; `\emergencystretch` is already set |
| `Undefined control sequence` | Package not loaded or typo | Load the package in the preamble; the full TeX Live image contains every CTAN package it distributes |
| `File 'x.sty' not found` | Package outside TeX Live, or a typo in its name | Check the name on CTAN; packages not in TeX Live must be added to the project, for example under `src/` |
| SVG figure text in the wrong font | SVG's `font-family` not installed in the image | Use an installed family in the SVG, or install the font |
| SVG conversion failed | Invalid SVG or unsupported feature | Validate the SVG; `rsvg-convert` does not run scripts or fetch external resources |
| PDF unchanged after edits | latexmk saw no change (e.g. only an asset outside src/ changed) | `latex.sh build DIR --clean` |
| Need a newer TeX Live | The `FROM` line is pinned to one digest | Pick a newer digest of `docker.io/texlive/texlive:latest`, edit `FROM` in the Containerfile, rebuild, and re-run all checks |
| `Incomplete bcf_file` / `*-SAVE-ERROR` files after a failed run; citations undefined afterwards | latexmk kept biber state from the failed run | `latex.sh build DIR --clean` |
| `Option clash for package hyperref` | A package that loads hyperref (attachfile2) came first | Load it after hyperref |
| `Undefined control sequence \text` in math | amsmath not loaded | Load amsmath, or write the formula as plain text |
| `tagpdf Error: The number of automatic begin ... and end ...` | listings in a tagged document | Use piton (code-and-attachments.md) |
| `Missing number, treated as zero` at `\begin{enumerate}[leftmargin=*]` | enumitem options in a tagged document | Remove enumitem; use `\setcounter{enumi}{N}` to continue numbering |
| `\lst@g...` undefined | Brackets in listings `morekeywords` | Use a delimiter for `[...]`, or piton |
| Link or `\nameref` jumps to the wrong place or prints nothing | Label after `\section*` with no anchor or name | Use the template's `\unnumsec` / `\appsection` |
| `Destination 'section*.N' has no related structure` | `\phantomsection` in a tagged document | Drop it when tagging; the template does this |
| Blank page before a code listing | piton box with background colour, not splittable | `\PitonOptions{splittable=4}` |
| `Overfull \vbox ... while \output is active` | A float plus a non-floating table taller than the rest of the page | Shrink the figure or let it float `[tbp]` |
| `veraPDF did not produce a report` | No `build/output.pdf` yet, or the veraPDF image failed to start | Build first; run the veraPDF image by hand to see its error |
| veraPDF "P shall not contain P / Part", or showtags "Part not allowed" | Unwrapped piton listings | Use the tagged wrapper (code-and-attachments.md) |
| veraPDF 8.9.2.4.10 AFRelationship | attachfile2 annotations | Use embedfile with `afrelationship={/Supplement}` |
| veraPDF 8.4.5.3.2 CIDToGIDMap | A TrueType font, in the text or inside an included figure PDF | Switch to OpenType fonts (fonts.md), including SVG `font-family` |
| Monospace text much wider than expected | `Scale=MatchLowercase` on a small-x-height font (Courier, TeX Gyre Cursor) | Drop the scaling, or use Source Code Pro |
| `\path{a, b c}` prints `a,bc` | `\path` drops spaces | Pass a single path; put prose outside the macro |
| Words run together in text built inside `\ExplSyntaxOn` | Spaces are ignored in expl3 syntax | Use `~` for every space |
| File "not found" in the container right after an edit (macOS or Windows Podman machine) | The VM briefly sees the old file | Rerun the build |
