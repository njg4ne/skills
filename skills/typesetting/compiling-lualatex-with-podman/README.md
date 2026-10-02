# compiling-lualatex-with-podman

An agent skill that turns LaTeX into a PDF without installing TeX. It scaffolds a
LuaLaTeX project, builds it in a Podman (or Docker) container, and checks the result:
chosen fonts and layout, SVG figures, a tagged accessible PDF (PDF/UA-2), highlighted
code listings, and file attachments. It works on macOS, Linux, and Windows.

This README is for people. The agent reads [`SKILL.md`](SKILL.md).

## Requirements

- Podman (or Docker). On macOS and Windows, a running Podman machine (`podman machine start`).
- A POSIX shell, or PowerShell 5.1+ on Windows.
- Disk space for the TeX Live image (several GB, pulled on the first build).

## Install

With the [skills](https://skills.sh) CLI (needs Node.js), from your project's root:

```sh
npx skills@latest add njg4ne/skills --skill compiling-lualatex-with-podman --agent universal
```

This copies the skill to `.agents/skills/compiling-lualatex-with-podman/`. Add `-g` to
install it for your user instead of one project. Leave out `--agent universal` to pick
specific agents from a list.

Update or remove it later:

```sh
npx skills@latest update compiling-lualatex-with-podman
npx skills@latest remove compiling-lualatex-with-podman
```

Without Node.js, or to pin this release, copy the folder by hand:

```sh
git clone --depth 1 --branch compiling-lualatex-with-podman/v2.1 \
  https://github.com/njg4ne/skills.git /tmp/njg4ne-skills
mkdir -p .agents/skills
cp -R /tmp/njg4ne-skills/skills/typesetting/compiling-lualatex-with-podman .agents/skills/
```

## Use

Ask your agent for a PDF, for example: "Make a 12pt report on letter paper in TeX Gyre
Heros, with my SVG chart, as an accessible PDF." The agent asks for any missing settings,
then scaffolds and builds.

You can also run the launcher yourself:

```sh
S=.agents/skills/compiling-lualatex-with-podman/scripts
$S/latex.sh scaffold ./report --title "My Report" --author "A. Author"
$S/latex.sh build ./report        # PDF at report/build/output.pdf
$S/latex.sh check-pdf ./report    # tagging, fonts, title, attachments
$S/latex.sh verapdf ./report      # PDF/UA-2 validation
```

On Windows, use `scripts\latex.ps1` with the same commands. A scaffolded project
carries its own build tool, so it also builds without the skill installed.

## License

Copyright (C) 2026 Nicholas Gardella. AGPL-3.0-or-later ([`LICENSE.txt`](LICENSE.txt)).
The files this skill places in your project are MIT, and your documents are yours. See
[`NOTICE.md`](NOTICE.md).
