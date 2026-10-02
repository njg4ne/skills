# Working in this repository

This repository holds agent skills in the open Agent Skills format. Keep every skill
agent-neutral: no files, fields, or instructions that only one agent understands.

- **Layout.** Each skill lives at `skills/<area>/<skill-name>/`. The folder name equals
  the `name` field in `SKILL.md`, and is unique across all areas. The areas are listed in
  `README.md`; add an area there when you create its first skill.
- **Self-contained.** A skill must work when copied alone. It refers only to files inside
  its own folder, and it carries `LICENSE.txt` (identical to the root `LICENSE`) and a
  `NOTICE.md` that lists its project files (files it copies into a user's project).
- **Versions.** Bump `metadata.version` in `SKILL.md` for every user-visible change. Tag
  a release `<skill-name>/v<version>`. Update the table in `README.md` when you add a skill.
- **Code style.** Shell is POSIX `sh` with `set -eu` and the `die`/`info` helpers. Keep
  comments as sparse as the surrounding code. Tools run in containers, not on the host.
- **Evals.** Add an entry to the skill's `evals/evals.json` for each new behavior.
- **Validate** before every commit:

  ```sh
  podman build -t skill-tools -f ci/Containerfile ci
  podman run --rm -v "$PWD:/work:Z" -w /work skill-tools sh ci/check.sh
  ```
