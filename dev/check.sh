#!/bin/sh
# Validate every skill in this repository. Runs INSIDE the dev/Containerfile
# image, with the repository mounted at /work; dev/validate.sh starts it.
# Checks: the Agent Skills spec (skills-ref), unique skill names, a license and
# notice in each skill, valid eval JSON, and shellcheck on every shell script.
set -eu

die()  { printf 'error: %s\n' "$*" >&2; exit 1; }
info() { printf '%s\n' "$*" >&2; }

cd /work 2>/dev/null || die "repository not mounted at /work"
status=0
names=" "

for md in skills/*/*/SKILL.md; do
  [ -e "$md" ] || die "no skills found at skills/<area>/<skill>/SKILL.md"
  dir=${md%/SKILL.md}
  name=${dir##*/}
  info "== $dir"
  # skills-ref also checks that the frontmatter name matches the directory name.
  skills-ref validate "$dir" || status=1
  # Installers flatten areas into one skills directory, so names must be unique.
  case "$names" in *" $name "*) echo "duplicate skill name: $name"; status=1 ;; esac
  names="$names$name "
  cmp -s LICENSE "$dir/LICENSE.txt" || { echo "$dir/LICENSE.txt is missing or differs from LICENSE"; status=1; }
  [ -f "$dir/NOTICE.md" ] || { echo "$dir/NOTICE.md is missing"; status=1; }
  for j in "$dir"/evals/*.json; do
    [ -e "$j" ] || continue
    python3 -m json.tool "$j" > /dev/null || { echo "invalid JSON: $j"; status=1; }
  done
done

# Shell scripts, at warning severity and up: every *.sh file, plus extensionless
# files with an sh shebang (such as tools/latexctl).
info "== shellcheck"
scripts=$(find skills dev -type f | while IFS= read -r f; do
  case "${f##*/}" in
    *.sh) echo "$f" ;;
    *.*) ;;
    *) head -n 1 "$f" | grep -q '^#!/bin/sh' && echo "$f" ;;
  esac
done)
# shellcheck disable=SC2086 # word splitting is intended; paths have no spaces
shellcheck -s sh -S warning $scripts || status=1

[ "$status" -eq 0 ] && info "all checks passed"
exit "$status"
