#!/bin/sh
# Host launcher (macOS, Linux). The only code that runs on the host: it starts
# containers, and all work happens inside them. Windows: use latex.ps1, which
# takes the same commands.
#
# Usage: latex.sh COMMAND PROJECT_DIR [ARGS]
#   scaffold  PROJECT_DIR [options]   create a project (options: see SKILL.md)
#   build     PROJECT_DIR [--clean]   build the PDF and check the log
#   check-log PROJECT_DIR             re-check the last LaTeX log
#   render    PROJECT_DIR [FIRST [LAST]] [--dpi N]
#   check-pdf PROJECT_DIR             metadata, tagging, fonts, bookmarks, attachments
#   verapdf   PROJECT_DIR [ua1|ua2]   accessibility validation (default ua2)
# Set ENGINE=docker to use Docker instead of Podman.
set -eu

ENGINE=${ENGINE:-podman}
IMAGE=localhost/lualatex-build
# Helper images, pinned by digest so runs are repeatable.
SCAFFOLD_IMAGE=docker.io/library/busybox@sha256:bd44eb136a95dcc8dc58995e43abc40a413f2e8e3d4a2aae6bccbe94686acb05
VERAPDF_IMAGE=${VERAPDF_IMAGE:-docker.io/verapdf/cli@sha256:d5ee329657cf9bc4b2400392dd54c7d0a0ce9980ff6fa2da5590eebeec007cdb}
SKILL=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

cmd=${1:-}; dir=${2:-}
[ -n "$cmd" ] && [ -n "$dir" ] || { sed -n '6,13p' "$0" >&2; exit 2; }
shift 2

# Files written in the container belong to the caller: keep-id maps the host UID
# (rootless Podman, Podman machine); Docker gets the caller's UID and GID.
case "$ENGINE" in
  podman) user_arg=--userns=keep-id ;;
  *)      user_arg="--user=$(id -u):$(id -g)" ;;
esac

if [ "$cmd" = scaffold ]; then
  mkdir -p "$dir"
  P=$(CDPATH='' cd -- "$dir" && pwd)
  exec "$ENGINE" run --rm "$user_arg" -v "$SKILL:/skill:ro" -v "$P:/work" \
    "$SCAFFOLD_IMAGE" sh /skill/scripts/scaffold.sh --dir /work "$@"
fi

P=$(CDPATH='' cd -- "$dir" 2>/dev/null && pwd) || { echo "error: no project at $dir" >&2; exit 1; }
[ -f "$P/Containerfile" ] || { echo "error: $P/Containerfile missing; run scaffold first" >&2; exit 1; }
mkdir -p "$P/build"

# Rebuild the image every run; the layer cache makes an unchanged Containerfile
# take seconds. The first build pulls TeX Live (several GB).
echo "image: building (log: build/image-build.log)" >&2
"$ENGINE" build -t "$IMAGE" -f "$P/Containerfile" "$P" > "$P/build/image-build.log" 2>&1 ||
  { tail -n 20 "$P/build/image-build.log" >&2; echo "error: image build failed" >&2; exit 1; }

if [ "$cmd" = verapdf ]; then
  flavour=${1:-ua2}
  case "$flavour" in ua1|ua2) ;; *) echo "error: flavour must be ua1 or ua2" >&2; exit 2 ;; esac
  echo "verapdf: validating build/output.pdf as PDF/$flavour (slow on arm64)" >&2
  # veraPDF writes its own report inside the container, so no host redirect is needed.
  "$ENGINE" run --rm -v "$P:/work" --entrypoint sh "$VERAPDF_IMAGE" -c \
    "/opt/verapdf/verapdf --flavour $flavour --format xml /work/build/output.pdf > /work/build/verapdf.xml 2>/dev/null; exit 0"
  cmd=verapdf-report
  set --
fi

exec "$ENGINE" run --rm "$user_arg" -e HOME=/tmp -v "$P:/work" -w /work "$IMAGE" \
  sh tools/latexctl "$cmd" "$@"
