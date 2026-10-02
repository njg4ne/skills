#!/bin/sh
# Create a LuaLaTeX project that compiles in a container.
# Runs INSIDE a small container started by the host launcher:
#   scripts/latex.sh scaffold DIR [options]      (macOS, Linux)
#   scripts\latex.ps1 scaffold DIR [options]     (Windows)
# Never overwrites existing files unless --force is given.
set -eu
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }
info() { printf '%s\n' "$*" >&2; }
SKILL_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

usage() { cat <<'U'
Usage: scaffold.sh --dir DIR [options]

  --dir DIR             project directory (created if missing)            [required]
  --main-font NAME      body font family, as fontconfig names it         [Latin Modern Roman]
  --sans-font NAME      sans family                                       [Latin Modern Sans]
  --mono-font NAME      monospace family                                  [Latin Modern Mono]
  --font-packages LIST  Debian packages for fonts outside TeX Live, space-separated [""]
  --size N              base size in pt: 8 9 10 11 12 14 17 20            [11]
  --spacing S           single | onehalf | double                         [single]
  --paper P             letter | a4 | legal | a5 | b5                     [letter]
  --margin LEN          uniform margin, TeX length (1in, 2.5cm)           [1in]
  --class C             article | report | book                           [article]
  --bib STYLE           none | numeric | authoryear | apa | ieee          [numeric]
  --language L          babel language name                               [english]
  --lang TAG            PDF language tag (BCP 47) for tagged output       [en-US]
  --tagged yes|no       tagged PDF 2.0 for assistive technology           [yes]
  --title TEXT          document title                                    [Untitled]
  --author TEXT         author name                                       [""]
  --main NAME           main .tex file name                               [manuscript.tex]
  --base-image REF      TeX Live image, pinned by digest                  [texlive/texlive TL2026 digest]
  --compose             also write compose.yml (optional convenience)
  --force               overwrite existing generated files
U
}

DIR="" MAIN_FONT="Latin Modern Roman" SANS_FONT="Latin Modern Sans" MONO_FONT="Latin Modern Mono"
FONT_PACKAGES="" SIZE=11 SPACING=single PAPER=letter MARGIN=1in CLASS=article BIB=numeric
LANGUAGE=english LANG_TAG=en-US TAGGED=yes TITLE=Untitled AUTHOR="" MAIN_TEX=manuscript.tex
BASE_IMAGE=docker.io/texlive/texlive:latest@sha256:16c556aeb4095b47245fcd05db47061529e5df8fc8c04d97fb0f049055244526 COMPOSE=0 FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --dir) DIR=$2; shift ;;
    --main-font) MAIN_FONT=$2; shift ;;
    --sans-font) SANS_FONT=$2; shift ;;
    --mono-font) MONO_FONT=$2; shift ;;
    --font-packages) FONT_PACKAGES=$2; shift ;;
    --size) SIZE=$2; shift ;;
    --spacing) SPACING=$2; shift ;;
    --paper) PAPER=$2; shift ;;
    --margin) MARGIN=$2; shift ;;
    --class) CLASS=$2; shift ;;
    --bib) BIB=$2; shift ;;
    --language) LANGUAGE=$2; shift ;;
    --lang) LANG_TAG=$2; shift ;;
    --tagged) TAGGED=$2; shift ;;
    --title) TITLE=$2; shift ;;
    --author) AUTHOR=$2; shift ;;
    --main) MAIN_TEX=$2; shift ;;
    --base-image) BASE_IMAGE=$2; shift ;;
    --compose) COMPOSE=1 ;;
    --force) FORCE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; die "unknown option: $1" ;;
  esac
  shift
done

[ -n "$DIR" ] || { usage >&2; die "--dir is required"; }

# --- validate and translate choices -----------------------------------------
# Standard classes support only 10/11/12pt; the ext* classes add 8-20pt.
case "$SIZE" in
  10|11|12) CLASS_OUT=$CLASS ;;
  8|9|14|17|20)
    case "$CLASS" in article|report|book) CLASS_OUT="ext$CLASS" ;; esac ;;
  *) die "--size must be one of 8 9 10 11 12 14 17 20 (got '$SIZE')" ;;
esac
case "$CLASS" in article|report|book) ;; *) die "--class must be article, report, or book" ;; esac
case "$SPACING" in
  single) SPACING_CMD='\singlespacing' ;;
  onehalf) SPACING_CMD='\onehalfspacing' ;;
  double) SPACING_CMD='\doublespacing' ;;
  *) die "--spacing must be single, onehalf, or double" ;;
esac
case "$PAPER" in letter|a4|legal|a5|b5) ;; *) die "--paper must be letter, a4, legal, a5, or b5" ;; esac
case "$MARGIN" in *[0-9]in|*[0-9]cm|*[0-9]mm|*[0-9]pt) ;; *) die "--margin needs a unit: in, cm, mm, or pt (got '$MARGIN')" ;; esac
case "$MAIN_TEX" in *.tex) ;; *) MAIN_TEX="$MAIN_TEX.tex" ;; esac
# Tagging: PDF 2.0 with structure for assistive technology. No PDF/UA claim is
# declared; validate with the launcher's verapdf command before adding one.
case "$TAGGED" in
  yes) METADATA="\\DocumentMetadata{lang=$LANG_TAG, pdfversion=2.0, tagging=on}" ;;
  no)  METADATA='' ;;
  *) die "--tagged must be yes or no" ;;
esac
case "$BIB" in
  none)       BIBLATEX='' ; PRINTBIB='' ;;
  numeric)    BIBLATEX='\usepackage[style=numeric-comp,sorting=none]{biblatex}' ;;
  authoryear) BIBLATEX='\usepackage[style=authoryear]{biblatex}' ;;
  apa)        BIBLATEX='\usepackage[style=apa]{biblatex}' ;;
  ieee)       BIBLATEX='\usepackage[style=ieee]{biblatex}' ;;
  *) die "--bib must be none, numeric, authoryear, apa, or ieee" ;;
esac
if [ "$BIB" != none ]; then
  BIBLATEX="$BIBLATEX
\\addbibresource{refs.bib}"
  PRINTBIB='\printbibliography'
fi

# --- write files ---------------------------------------------------------------
mkdir -p "$DIR/src/figures"
PROJECT=$(CDPATH='' cd -- "$DIR" && pwd)

# Escape a value for use as a sed replacement with '|' as delimiter.
esc() { printf '%s' "$1" | sed -e 's/[\\|&]/\\&/g'; }

put() { # put SRC DEST: copy unless DEST exists and --force not given
  if [ -e "$2" ] && [ "$FORCE" -ne 1 ]; then info "kept existing $2"; return 1; fi
  cp "$1" "$2"; info "wrote $2"
}

if [ ! -e "$PROJECT/Containerfile" ] || [ "$FORCE" -eq 1 ]; then
  sed -e "s|@@BASE_IMAGE@@|$(esc "$BASE_IMAGE")|" -e "s|@@FONT_PACKAGES@@|$(esc "$FONT_PACKAGES")|" \
      "$SKILL_DIR/assets/Containerfile" > "$PROJECT/Containerfile"
  info "wrote $PROJECT/Containerfile"
else
  info "kept existing $PROJECT/Containerfile"
fi
# The image needs nothing from the project at build time; an empty build context
# keeps every rebuild fast on all engines.
printf '*\n' > "$PROJECT/.containerignore"
# The build tool travels with the project, so it builds without this skill installed.
mkdir -p "$PROJECT/tools"
put "$SKILL_DIR/tools/latexctl" "$PROJECT/tools/latexctl" || true
put "$SKILL_DIR/assets/latexmkrc" "$PROJECT/src/.latexmkrc" || true
put "$SKILL_DIR/assets/gitignore" "$PROJECT/.gitignore" || true
if [ "$BIB" != none ]; then put "$SKILL_DIR/assets/refs.bib" "$PROJECT/src/refs.bib" || true; fi

if [ ! -e "$PROJECT/src/$MAIN_TEX" ] || [ "$FORCE" -eq 1 ]; then
  sed -e "s|@@SIZE@@|$(esc "${SIZE}pt")|" \
      -e "s|@@METADATA@@|$(esc "$METADATA")|" \
      -e "s|@@PAPER@@|$(esc "${PAPER}paper")|" \
      -e "s|@@CLASS@@|$(esc "$CLASS_OUT")|" \
      -e "s|@@MARGIN@@|$(esc "$MARGIN")|" \
      -e "s|@@MAIN_FONT@@|$(esc "$MAIN_FONT")|" \
      -e "s|@@SANS_FONT@@|$(esc "$SANS_FONT")|" \
      -e "s|@@MONO_FONT@@|$(esc "$MONO_FONT")|" \
      -e "s|@@SPACING_CMD@@|$(esc "$SPACING_CMD")|" \
      -e "s|@@LANGUAGE@@|$(esc "$LANGUAGE")|g" \
      -e "s|@@TITLE@@|$(esc "$TITLE")|g" \
      -e "s|@@AUTHOR@@|$(esc "$AUTHOR")|g" \
      -e "s|@@PRINTBIB@@|$(esc "$PRINTBIB")|" \
      "$SKILL_DIR/assets/manuscript.tex" > "$PROJECT/src/$MAIN_TEX.tmp"
  # BIBLATEX may span two lines, so insert it with awk rather than sed.
  BIBLATEX=$BIBLATEX awk '{ if ($0 == "@@BIBLATEX@@") { if (ENVIRON["BIBLATEX"] != "") print ENVIRON["BIBLATEX"] } else print }' \
      "$PROJECT/src/$MAIN_TEX.tmp" > "$PROJECT/src/$MAIN_TEX"
  rm -f "$PROJECT/src/$MAIN_TEX.tmp"
  info "wrote $PROJECT/src/$MAIN_TEX"
else
  info "kept existing $PROJECT/src/$MAIN_TEX"
fi

if [ ! -e "$PROJECT/latex-build.env" ] || [ "$FORCE" -eq 1 ]; then
  cat > "$PROJECT/latex-build.env" <<ENV
# Read by tools/latexctl inside the build container. The base image and font
# packages live in the Containerfile.
MAIN_TEX='$MAIN_TEX'
# Font families that must resolve inside the image (checked on every build).
REQUIRED_FONTS='$MAIN_FONT|$SANS_FONT|$MONO_FONT'
# Whether the PDF should be tagged (checked by check-pdf).
TAGGED='$TAGGED'
# Optional hooks: project-relative scripts that build runs with sh in the container.
# PRE_BUILD runs before the font check, for example to zip files the PDF attaches.
# PRE_BUILD=''
# POST_BUILD runs after a clean build and gets the PDF path as \$1, for example to copy it.
# POST_BUILD=''
ENV
  info "wrote $PROJECT/latex-build.env"
else
  info "kept existing $PROJECT/latex-build.env"
fi

if [ "$COMPOSE" -eq 1 ]; then
  if [ ! -e "$PROJECT/compose.yml" ] || [ "$FORCE" -eq 1 ]; then
    cat > "$PROJECT/compose.yml" <<YML
# Optional convenience: "podman compose run --rm tex" builds the PDF.
# The launchers (latex.sh, latex.ps1) are the reference and do not need compose.
services:
  tex:
    build:
      context: .
      dockerfile: Containerfile
    volumes:
      - ./:/work
    working_dir: /work
    command: sh tools/latexctl build
YML
    info "wrote $PROJECT/compose.yml"
  fi
fi

info "next, from the host: scripts/latex.sh build DIR   (Windows: scripts\\latex.ps1 build DIR)"
