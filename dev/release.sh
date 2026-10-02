#!/bin/sh
# Release one skill, from the dev machine: validate every skill, tag the release
# <skill-name>/v<metadata.version>, and push the branch and the tag.
# Runs only git and podman on the host (validation runs in a container).
# Usage:  sh dev/release.sh SKILL_NAME [--no-push]
set -eu

die()  { printf 'error: %s\n' "$*" >&2; exit 1; }
info() { printf '%s\n' "$*" >&2; }

REPO=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$REPO"
name=${1:-}
[ -n "$name" ] || { sed -n '5p' "$0" >&2; exit 2; }
push=1
[ "${2:-}" = --no-push ] && push=0

set -- skills/*/"$name"/SKILL.md
[ -f "$1" ] || die "no skill named $name at skills/<area>/$name/"
version=$(sed -n 's/^  version: *"\{0,1\}\([^"]*\)"\{0,1\}[[:space:]]*$/\1/p' "$1")
[ -n "$version" ] || die "no metadata.version in $1"
tag="$name/v$version"

[ -z "$(git status --porcelain)" ] || die "uncommitted changes; commit them first"
if git rev-parse -q --verify "refs/tags/$tag" > /dev/null; then
  die "tag $tag already exists; bump metadata.version in $1"
fi

sh dev/validate.sh
git tag -a "$tag" -m "$name $version"
info "tagged $tag"
if [ "$push" -eq 1 ]; then
  git push origin "$(git branch --show-current)" "$tag"
else
  info "not pushed; to publish: git push origin $(git branch --show-current) $tag"
fi
