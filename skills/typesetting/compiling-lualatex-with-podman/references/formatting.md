# Translating formatting requests

| User says | Flags / preamble |
|---|---|
| "normal margins" (US) | `--margin 1in` (Word's default) |
| "normal margins" (A4/Europe) | `--margin 2.5cm` |
| "narrow margins" | `--margin 0.5in` |
| "wide margins" | `--margin 1.5in` (geometry: set `left`/`right` by hand if asymmetric) |
| "1.5 spacing", "one and a half" | `--spacing onehalf` (setspace `\onehalfspacing`) |
| "double spaced" | `--spacing double` |
| "size 12", "12-point" | `--size 12` |
| "14pt", "large print" | `--size 14` (switches to `extarticle`, `extreport`, `extbook`) |
| "US letter" | `--paper letter` |
| "A4" | `--paper a4` |
| chapters, front matter | `--class report` (chapters) or `--class book` (two-sided) |
| "APA" | `--bib apa` (biblatex-apa); APA papers also want `--spacing double --size 12` |
| "IEEE" | `--bib ieee` |
| "Chicago author-date" | `--bib authoryear` is close; exact Chicago needs `biblatex-chicago` (edit preamble) |
| "no references" | `--bib none` |

Notes:
- setspace's `\onehalfspacing` gives Word-like 1.5 spacing for the chosen size;
  it is not `\linespread{1.5}`, which is closer to double spacing.
- Margin widths apply to all four sides. For different sides, edit the
  `geometry` options in the preamble, for example `top=1in,bottom=1in,left=1.25in,right=1in`.
- Language: `--language` takes babel names (`english`, `british`, `german`, `french`).
