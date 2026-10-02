#!/bin/sh
# Validate every skill, from the dev machine. Runs only podman on the host; the
# checks (dev/check.sh) run inside the pinned dev/Containerfile image.
# Usage, from anywhere:  sh dev/validate.sh
# Set ENGINE=docker to use Docker instead of Podman.
set -eu

ENGINE=${ENGINE:-podman}
IMAGE=localhost/skill-tools
REPO=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

# Rebuild every run; the layer cache makes an unchanged Containerfile take seconds.
"$ENGINE" build -q -t "$IMAGE" -f "$REPO/dev/Containerfile" "$REPO/dev" > /dev/null
exec "$ENGINE" run --rm -v "$REPO:/work:Z" -w /work "$IMAGE" sh dev/check.sh
