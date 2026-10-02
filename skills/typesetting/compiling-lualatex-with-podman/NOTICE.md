# compiling-lualatex-with-podman: license and notices

Copyright (C) 2026 Nicholas Gardella

Licensed under the GNU Affero General Public License v3.0 or later (`LICENSE.txt`), with additional permission and additional terms under AGPL section 7 as stated in `NOTICE.md` at [https://github.com/njg4ne/skills](https://github.com/njg4ne/skills). In short:

- **Project files are MIT-licensed** once this skill places them in your project. Your documents are yours.
- **Modified versions of the skill** stay under the AGPL, must keep the attribution "Nicholas Gardella" with a link to the source, and must be marked as modified.

SPDX-License-Identifier: `AGPL-3.0-or-later` (with the project-files exception)

## Project files

These files are covered by the project-files exception. Once this skill has placed them in your project, you may use them under the MIT License instead of the AGPL:

- everything `scripts/scaffold.sh` writes: `Containerfile`, `.containerignore`, `latex-build.env`, `tools/latexctl`, `.gitignore`, `compose.yml`, `src/.latexmkrc`, `src/manuscript.tex`, and `src/refs.bib`
- every file under `assets/`, including `assets/snippets/code-and-attachments.tex` when you copy it into your project
