# Accessibility, headings, and links

## Contents
- Tagged PDF: what to enable and what breaks it
- Headings, bookmarks, and cross-references
- Figures, tables, and lists
- Validating, and what not to claim
- Layout details that affect reading

## Tagged PDF: what to enable and what breaks it

`latex.sh scaffold` defaults to `--tagged yes`, which makes the first line of the main file:

    \DocumentMetadata{lang=en-US, pdfversion=2.0, tagging=on}

It must come before `\documentclass`. `tagging=on` selects the kernel's current tagging
code; the default image provides it. It produces a PDF 2.0 file with a structure
tree (H1/H2 headings with number labels, paragraphs, lists, tables, figures, links)
that screen readers use. `latex.sh check-pdf` reports `Tagged: yes` when it works.

Package compatibility with tagging (tested with TeX Live 2025 and 2026):

| Package | Status | Use instead |
|---|---|---|
| titlesec | breaks heading tagging | class defaults (article already uses `\Large\bfseries` / `\large\bfseries`) |
| enumitem | `leftmargin=*` and `resume` stop the build ("Missing number") | plain `enumerate`; continue numbering with `\setcounter{enumi}{N}` after `\begin{enumerate}` |
| listings | stops the build ("number of automatic begin and end" mismatch) | `piton` with the tagged wrapper (see code-and-attachments.md) |
| piton, unwrapped | builds, but nests P inside P and Part (fails PDF/UA, and the LaTeX Project's structure validator reports "Part not allowed") | wrap each listing as one P/Code block |
| attachfile2 | builds, but its annotations lack AFRelationship (fails PDF/UA 8.9.2.4.10) | `embedfile` with `afrelationship` |
| amsmath-free math | `\text` undefined | write formulas as centred plain text, or load `amsmath` |
| tabularx, booktabs, hyperref, biblatex, setspace, csquotes, graphicx, embedfile, needspace | build and tag cleanly | n/a |

TeX Live 2026 also ships tagging support for enumitem (`latex-lab-enumitem`); test it
before relying on it.

## Headings, bookmarks, and cross-references

- Bookmarks (the PDF outline) need `bookmarksnumbered=true` in hyperref options, or they
  drop section numbers. Set `bookmarksdepth=2` explicitly when the printed contents
  use a smaller `tocdepth`. The template does both.
- Set `pdftitle` and `pdfdisplaydoctitle=true`, so viewers and screen readers show the
  title, not the file name.
- `\autoref` names (Section, Appendix, Figure) must be set inside `\addto\extras<language>`
  because babel resets them.
- Appendix headings that read "Appendix A: Title" everywhere (heading, contents,
  bookmarks, tag tree): use the template's `\appsection{Title}{label}` after `\appendix`.
  It steps the counter for the heading text, then re-steps it with `\refstepcounter`
  after the heading, so the anchor is `appendix.A` and `\autoref` prints "Appendix A".
  Avoid colons in appendix titles; "Appendix A: X: Y" reads badly.
- Unnumbered sections that need `\nameref`: use `\unnumsec{Title}{label}`. Without
  tagging it needs `\phantomsection` (otherwise the label points at the previous
  numbered anchor); with tagging, `\section*` makes its own anchor and
  `\phantomsection` causes "Destination has no related structure" warnings. The
  template switches on `\IfDocumentMetadataTF`.
- `\nameref` returns empty if `\@currentlabelname` is not set; the macros set it.
- Hard-coded "step 10" or "Section 3" goes stale. Label list items
  (`\item \label{step:x}`) and use `\ref` / `\autoref`.
- Audit after every build: the log check reports undefined references, and
  `latex.sh check-pdf` dumps the outline. For a deeper look, inspect inside the
  image, for example
  `podman run --rm -v "$PWD:/work" -w /work/src localhost/lualatex-build sh -c "grep newlabel manuscript.aux; pdftotext manuscript.pdf - | grep -c '??'"`.

## Figures, tables, and lists

- Give every figure alternative text: `\includegraphics[alt={...}]{file}`. Describe what
  the figure shows, not its file name. Without it the tagger warns and uses the file name.
- Tables without captions should not float: use `center` + `tabularx`, not `table`, or
  they drift away from their heading.
- Keep figures in SVG and convert at build time; text in SVG must use an installed font.

## Validating, and what not to claim

- `latex.sh verapdf DIR` runs veraPDF (PDF/UA-2 by default; `ua1` also accepted) in
  its own container and lists failed rules.
- Do not add `pdfstandard=ua-2` (a conformance claim) unless veraPDF passes. The
  failures we have met, and their fixes:
  - 8.4.5.3.2 CIDToGIDMap: TrueType fonts under LuaTeX (Liberation, DejaVu, most
    system fonts). Use OpenType/CFF fonts (fonts.md), in SVG figures too, because
    fonts inside included PDFs are checked as well.
  - P containing P / Part: unwrapped piton listings. Use the tagged wrapper.
  - 8.9.2.4.10 AFRelationship: attachfile2 annotations. Use embedfile with afrelationship.
  - Clause 5, PDF/UA identification: expected until `pdfstandard=ua-2` is declared.
- Tested result: a 57-page document with OpenType fonts (TeX Gyre Heros, Source Code
  Pro, also in its SVG figures), 18 wrapped piton listings, 17 embedfile attachments,
  tables, figures with alt text, appendices, and a bibliography passed all 1,727
  PDF/UA-2 rules (veraPDF 1.30.2) on TeX Live 2026 with
  `\DocumentMetadata{lang=en-US, pdfversion=2.0, pdfstandard=ua-2, tagging=on}`.
- So: validate first, and add `pdfstandard=ua-2` only when every rule passes. If any
  rule still fails, leave the key out and report the failures.
- The LaTeX Project's online structure checker (showtags) validates the tag tree
  against its schema and catches nesting errors as well.
- Report the remaining failures honestly in the document's limits or colophon.

## Layout details that affect reading

- Contents pages: single-space them and set `\parskip` to 0 inside the group, or the
  document's paragraph spacing applies to every entry:
  `\begin{singlespace}\setlength{\parskip}{0pt}\tableofcontents\end{singlespace}`.
- Shorten long contents by listing appendices by title only:
  `\addtocontents{toc}{\protect\setcounter{tocdepth}{1}}` right after `\appendix`.
- Abbreviations ending in a period need a normal space: `7\,a.m.\ to`.
- Paths and URLs: use `\path{...}` so they break at slashes; `\path` drops spaces, so
  split commands with spaces into separate `\texttt` pieces.

## Old patterns

<details>
<summary>TeX Live 2025 and earlier (for example Debian trixie's TeX Live)</summary>

These releases do not accept `tagging=on`. Use
`\DocumentMetadata{lang=en-US, pdfversion=2.0, testphase={phase-III,title,table,firstaid}}`.
Their piton and tagging code produce more nesting errors, so prefer the default image.
</details>

