# Fonts

## Contents
- Choosing a font and its Debian package
- Verifying a font name
- Fonts not packaged in Debian

## Choosing a font and its Debian package

The default image is the full TeX Live scheme, so many fonts need no package. Checked
in TeX Live 2026 as OpenType (CFF): Latin Modern, TeX Gyre (Heros, Termes, Cursor,
Pagella, Schola, Bonum), Source Code Pro, Source Sans 3, Source Serif 4, Fira Sans and
Mono, Libertinus, Inter, EB Garamond, IBM Plex, JetBrains Mono, Roboto. In TeX Live but
TrueType: Noto, Carlito. Check a
name with `luaotfload-tool --find="Name"` in the image. Use `--font-packages` only for
fonts outside TeX Live (Debian packages, installed with apt in the image).

Prefer OpenType (CFF, `.otf`) fonts. LuaTeX embeds TrueType (`.ttf`) fonts in a way that
fails PDF/UA rule 8.4.5.3.2 (CIDToGIDMap), so a TrueType font rules out a PDF/UA claim.

| Wanted | OpenType choice in TeX Live | Notes |
|---|---|---|
| Liberation Sans / Arial / Helvetica | TeX Gyre Heros | Liberation is TrueType only |
| Liberation Serif / Times New Roman | TeX Gyre Termes | |
| Liberation Mono / Cousine | Source Code Pro (`Scale=MatchLowercase`) | sans-serif mono, close to Liberation Mono |
| Courier New | TeX Gyre Cursor | light; do not scale with MatchLowercase (it grows about 23%) |
| Palatino / Century Schoolbook / Bookman | TeX Gyre Pagella / Schola / Bonum | |
| Computer Modern look | Latin Modern Roman / Sans / Mono | default |
| Calibri (not redistributable) | Carlito | in TeX Live; TrueType, so no PDF/UA claim; metric-compatible |
| Cambria (not redistributable) | Caladea | Debian fonts-crosextra-caladea; TrueType |

When a user names a font that is missing or not redistributable, substitute from this
table without asking only if told not to ask, and always say what you substituted and why.

TrueType options, when the user insists and accepts no PDF/UA claim: Liberation
(not in TeX Live; Debian fonts-liberation2), DejaVu (fonts-dejavu-core), Noto and
Carlito (in TeX Live), Caladea (fonts-crosextra-caladea). Carlito and Caladea match
Calibri and Cambria metrics.

Microsoft fonts (Times New Roman, Arial, Calibri) are not redistributable.
Offer the metric-compatible substitute above, or use the local-files method below
if the user has a licence and the files.

## Verifying a font name

The build checks every name in `REQUIRED_FONTS` and stops with the missing names.
After one build, the image is tagged `localhost/lualatex-build`; search its fonts
inside the container (the same command works in PowerShell):

```sh
podman run --rm localhost/lualatex-build sh -c "luaotfload-tool --find='TeX Gyre Heros'; fc-list : family | sort -u | grep -i heros"
```

For a font outside TeX Live, append its Debian package to the `apt-get install` line
in the project's Containerfile. If the name is wrong, the image build fails at
`apt-get install` (see `build/image-build.log`); search https://packages.debian.org
(the TeX Live image is based on Debian testing).

## Fonts not packaged in Debian

1. Put the `.otf`/`.ttf` files in `src/fonts/`.
2. Load them by file name, for example:
   `\setmainfont{MyFont}[Path=fonts/, Extension=.otf, UprightFont=*-Regular, BoldFont=*-Bold, ItalicFont=*-Italic, BoldItalicFont=*-BoldItalic]`
3. Remove that family from `REQUIRED_FONTS` in `latex-build.env` (the check only
   sees installed fonts).
4. Respect the font's licence before committing the files.
