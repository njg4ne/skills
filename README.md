# Skills

Agent skills by [Nicholas Gardella](https://n.gardella.cc/), for teaching, research, and
the tools around them.

Each skill is a folder with a `SKILL.md`, in the open
[Agent Skills](https://agentskills.io) format. Nothing here is tied to one agent: any
agent that reads Agent Skills can use them. Skills are self-contained. Each one carries
its own scripts, references, license, and notice, so you can install one without the
rest.

## Skills

| Area | Skill | What it does |
|---|---|---|
| typesetting | [compiling-lualatex-with-podman](skills/typesetting/compiling-lualatex-with-podman/SKILL.md) | Scaffolds, builds, and checks LuaLaTeX documents in Podman or Docker containers: chosen fonts and layout, SVG figures, tagged accessible PDF (PDF/UA-2), code listings, and file attachments. Nothing runs on the host. |

## Install

Install one skill at a time. Pick one of these routes.

**With the [skills](https://skills.sh) installer**, into the project's `.agents/skills/`:

```sh
npx skills@latest add njg4ne/skills --skill compiling-lualatex-with-podman --agent universal
```

**By hand:** copy the skill's folder into `.agents/skills/` in your project (or
`~/.agents/skills/` for all your projects). Keep the folder name, because it must
match the skill's `name`.

```sh
git clone --depth 1 https://github.com/njg4ne/skills.git /tmp/njg4ne-skills
mkdir -p .agents/skills
cp -R /tmp/njg4ne-skills/skills/typesetting/compiling-lualatex-with-podman .agents/skills/
```

To pin a version, clone a skill's tag instead, for example
`git clone --depth 1 --branch compiling-lualatex-with-podman/v2.1 …`.

## Layout

```
skills/<area>/<skill-name>/
├── SKILL.md        instructions and frontmatter (name, description, license, metadata.version)
├── LICENSE.txt     copy of the AGPL, so the skill stays licensed when copied alone
├── NOTICE.md       copyright, and which files are MIT once placed in your project
├── scripts/  tools/  assets/  references/  evals/    as the skill needs
```

Areas group skills for browsing only. Installers flatten them, so every skill name is
unique across the repository. An area folder appears when its first skill does. Planned
areas:

| Area | For |
|---|---|
| `typesetting` | LaTeX, PDF, and accessible documents |
| `education` | course design, the LMS (Canvas), assessment and quizzes |
| `computing-education` | CS courses: programming assignments, autograding, course infrastructure |
| `computing-education-research` | study design, IRB, data collection, qualitative and quantitative analysis |
| `research` | general research work: qualitative data analysis, HCI studies, writing and reviewing papers |
| `accessibility` | accessible documents, web pages, and course materials |
| `web` | web apps and APIs, browser hardware interfaces (Web Bluetooth) |
| `infrastructure` | containers, research cloud (Jetstream2), self-hosted services |
| `lang-<language>` | language-specific practice: `lang-python`, `lang-typescript`, `lang-go`, `lang-swift` |

## Versions

Each skill has its own version in `metadata.version`. A release is tagged
`<skill-name>/v<version>`, for example `compiling-lualatex-with-podman/v2.1`.

## Validate

All checks run in a container. The same commands run in CI on every push.

```sh
podman build -t skill-tools -f ci/Containerfile ci
podman run --rm -v "$PWD:/work:Z" -w /work skill-tools sh ci/check.sh
```

## License

Copyright (C) 2026 Nicholas Gardella. Licensed under the **GNU Affero General Public
License v3.0 or later** (`AGPL-3.0-or-later`), with two kinds of section 7 terms:

- an additional permission: the files a skill places in your project (build scripts,
  templates) are yours to use under the **MIT License**
- additional terms: modified skills must keep the attribution and be marked as modified,
  and the license grants no trademark rights

What you make with a skill is yours. See [`NOTICE.md`](NOTICE.md) for the full terms.
