# Code listings and file attachments

## Contents
- Highlighted code with piton
- Keeping headers with code
- Attaching files to the PDF
- Viewer support
- Including files from outside src/

## Highlighted code with piton

Ready to use: `assets/snippets/code-and-attachments.tex` holds the tested preamble
code below (languages, styles, the tagged wrapper, and a `\codefile` command that
prints a file and attaches it). Copy it into `src/` and `\input` it. A document using
it passed all PDF/UA-2 rules. Its two commands:

    \codefile{language}{path from src/}{saved name}{one-line description}
    % e.g. \codefile{sh}{../config/deploy.sh}{deploy.sh}{Deployment script}
    % prints a bold header, embeds the file (AFRelationship /Supplement), and
    % typesets it as one tagged code block

    \taggedcode{\PitonInputFile[language=sh]{../config/deploy.sh}}
    % typesets only, without attaching

Languages defined in the snippet: `sh` and `unit` (systemd, Quadlet, INI). Add others
with `\NewPitonLanguage` as shown below.

Use `piton` (LuaLaTeX only), not `listings`, which breaks tagged builds. It typesets in
the document's monospace font (`\setmonofont`), so code follows the user's font choice.

    \usepackage{piton}
    \NewPitonLanguage{sh}{morekeywords={if,then,elif,else,fi,for,in,do,done,while,case,esac,set,exit,return,export},
      morecomment=[l]\#, morestring=[b]", morestring=[b]', sensitive=true}
    \NewPitonLanguage{unit}{morecomment=[l]\#, moredelim=[s][\color{blue!60!black}\bfseries]{[}{]}, sensitive=true}
    \SetPitonStyle{Comment = \color{gray!80!black}\itshape, Keyword = \color{blue!60!black}\bfseries,
      String = \color{red!50!black}, Number = {}}
    \PitonOptions{break-lines, background-color=gray!7, splittable=4, line-numbers}

- Built-in languages: Python, OCaml, C, SQL, minimal, verbatim. Define others with
  `\NewPitonLanguage` using listings-style keys (`unit` above covers systemd, Quadlet,
  and INI files).
- Do not put `[Section]`-style words in `morekeywords`; brackets break listings-style
  parsing. Use `moredelim=[s]{[}{]}` as above.
- `Number = {}` stops digits inside names (`Qwen3.5-9B`) from being coloured.
- With a background colour, a listing is one unbreakable box unless `splittable` is set;
  without it, long listings jump to the next page and leave a blank one.
- Wrap listings in `\footnotesize` (or `\small`) at 12pt body size to limit wrapping.
- Do not use captions on listings in tagged documents (invalid structure). Put the file
  name and location in a normal paragraph above the listing.
- In tagged documents, wrap every listing so it is tagged as one block, a P containing a
  Code element, the way the kernel tags verbatim. Unwrapped, piton's per-line paragraphs
  nest P inside P and Part, which PDF/UA forbids. The wrapper uses documented tagpdf
  commands only:

      \NewDocumentCommand{\taggedcode}{m}{%
        \par\begingroup
        \tagpdfsetup{para/tagging=false}%
        \tagstructbegin{tag=P}\tagstructbegin{tag=Code}\tagmcbegin{}%
        \footnotesize #1%
        \tagmcend\tagstructend\tagstructend
        \endgroup\par}
      \taggedcode{\PitonInputFile[language=sh]{script.sh}}

  A `Piton` environment is verbatim and cannot be a macro argument; write the same
  begin and end commands around it in place.
- Long hashes and URLs cannot wrap at spaces: add `break-strings-anywhere,
  break-numbers-anywhere` to `\PitonOptions`.
- Read code from the real file (`\PitonInputFile[language=sh]{path}`), so the printed
  code and the shipped file cannot drift apart. Inline: `\begin{Piton}[language=sh] ... \end{Piton}`.

## Keeping headers with code

A header paragraph can end a page while its listing starts the next. Load `needspace`
and reserve space before the header: `\needspace{8\baselineskip}`. Do the same before
subsection headings in a code-heavy section (`\needspace{12\baselineskip}`), or the
header's reserved space orphans the subsection heading instead.

## Attaching files to the PDF

Use document-level embedded files declared as PDF 2.0 associated files:

    \usepackage{embedfile}
    \embedfile[desc={what it is}, mimetype=text/plain,
               afrelationship={/Supplement}, ucfilespec={name.ext}]{path/to/file}

- This adds the file to the attachments panel and to the catalog's `/AF` array, and
  passes PDF/UA-2. Readers open files from the viewer's attachments panel.
- `ucfilespec` sets the file name a viewer saves; without it the build path
  (`../repo/dir/file`) becomes the name.
- Clickable in-text links (attachfile2's `\textattachfile`) are convenient but fail
  PDF/UA 8.9.2.4.10; use them only when no conformance claim is needed, and load
  attachfile2 after hyperref (it loads hyperref itself, so "Option clash" otherwise).
- Use `mimetype=application/zip` for archives. Build the zip inside the container
  (`zip -qrX`, excluding `.DS_Store`) before LaTeX runs, so the PDF and zip match:
  put the `zip` command in a script and name it as `PRE_BUILD` in `latex-build.env`.
- Do not attach the same file with both `\embedfile` and `\textattachfile`; it is
  stored twice.
- Verify with `latex.sh check-pdf` (lists attachments), or extract and compare inside
  the image: `pdfdetach -saveall manuscript.pdf`, then `cmp` against the source file.

## Viewer support

| Viewer | Attachments |
|---|---|
| Firefox (pdf.js) | click the link, or sidebar → Attachments |
| Adobe Acrobat Reader | click or paperclip panel; refuses to open blocked types (`.sh`, unknown extensions, files without extension, often `.zip`) whatever the user's attachment setting; Save Attachment still works |
| Okular, Evince | side panel |
| Apple Preview, Quick Look | not shown at all |

Tell readers which viewers work. If Acrobat must open files directly, attach copies
with a `.txt` suffix.

## Including files from outside src/

The launcher mounts the whole project directory at `/work` and the build compiles in
`/work/src`, so any file inside the project is reachable as `../dir/file`. Files
outside the project are not visible to the build: copy them into the project (for
example `project/config/`) first.
