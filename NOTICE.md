# License and notices

Agent skills by Nicholas Gardella
Copyright (C) 2026 Nicholas Gardella

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program (the `LICENSE` file, also copied into each skill as `LICENSE.txt`). If not, see [https://www.gnu.org/licenses/](https://www.gnu.org/licenses/).

SPDX-License-Identifier: `AGPL-3.0-or-later` (with the project-files exception below)

Source code: [https://github.com/njg4ne/skills](https://github.com/njg4ne/skills)

## What this license means in practice

This is a plain-language summary, not legal advice. The `LICENSE` file and the terms below are what govern.

- **You may** install, use, study, copy, modify, and share these skills, with any agent, for any purpose.
- **What you make with a skill is yours.** Documents, code, and other content you or your agent produce while using a skill are not covered by this license.
- **Files a skill puts into your project are MIT-licensed** (see the exception below). For example, the build files that `compiling-lualatex-with-podman` scaffolds into your document project carry no copyleft obligations.
- **If you share a modified skill**, or **run one as a service other people use**, you must make its complete source available to them under this same license.
- **There is no warranty.** Check what an agent does with a skill before you rely on it.

## Additional permission under AGPL section 7: project-files exception

Some skills copy files into, or generate files in, the project of the person who uses the skill. Each skill's `NOTICE.md` lists these files under "Project files".

As a special exception, the copyright holder gives you permission to use, copy, modify, merge, publish, distribute, sublicense, and sell the project files, once a skill has placed them in your project, under the terms of the MIT License below instead of the GNU Affero General Public License. You may remove this exception from a modified version of a skill; if you do, the project files of that version are under the AGPL only.

This exception covers only the project files as placed in your project. A skill itself (its `SKILL.md`, references, scripts, and its copies of the project files) stays under the AGPL when you distribute it, modified or not.

```
MIT License

Copyright (c) 2026 Nicholas Gardella

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Additional terms under AGPL section 7

As permitted by section 7(b), 7(c) and 7(e) of the GNU Affero General Public License, version 3, the following additional terms apply to the skills (they do not restrict project files used under the MIT exception above):

1. **Attribution (7(b)).** Modified versions of a skill must keep the author attribution "Nicholas Gardella" (for example in the `metadata.author` field of `SKILL.md` or in its `NOTICE.md`) together with a link to [https://github.com/njg4ne/skills](https://github.com/njg4ne/skills).
2. **Marking modified versions (7(c)).** Modified versions must be clearly marked as different from the original, for example by adding a "modified by" line to `NOTICE.md` or changing the skill's `name`. They must not be presented as the original author's version.
3. **No trademark rights (7(e)).** This license grants no rights to use the names, logos, or trademarks of Washington and Lee University, of Nicholas Gardella, or of any other party mentioned here, except as needed to describe where the work came from.

## Trademarks and other names

- **Washington and Lee University** and "W&L" belong to Washington and Lee University. These skills are the author's own work. They are not an official university product, and W&L does not endorse them unless the university says so.
- **Podman** is a trademark of Red Hat, Inc. **Docker** is a trademark of Docker, Inc. Other names belong to their owners. No affiliation or endorsement is implied.

## Third-party components

This repository contains only original files. Container images that the skills pull at run time (for example TeX Live, BusyBox, and veraPDF) are downloaded from their publishers and are under their own licenses.

## AI-assisted development

Parts of these skills were drafted with AI tools under the direction and review of Nicholas Gardella. Commit messages record AI co-authorship. The copyright claimed above covers the human-authored creative work: the concept, architecture, requirements, design decisions, selection and arrangement, and edits. Any purely machine-generated material that is not eligible for copyright is still provided under the same terms, to the extent anyone holds rights in it.
