# Host launcher (Windows PowerShell 5.1 and PowerShell 7). The only code that runs
# on the host: it starts containers, and all work happens inside them. macOS and
# Linux: use latex.sh, which takes the same commands.
#
# Usage: latex.ps1 COMMAND PROJECT_DIR [ARGS]
#   scaffold  PROJECT_DIR [options]   create a project (options: see SKILL.md)
#   build     PROJECT_DIR [--clean]   build the PDF and check the log
#   check-log PROJECT_DIR             re-check the last LaTeX log
#   render    PROJECT_DIR [FIRST [LAST]] [--dpi N]
#   check-pdf PROJECT_DIR             metadata, tagging, fonts, bookmarks, attachments
#   verapdf   PROJECT_DIR [ua1|ua2]   accessibility validation (default ua2)
# Set $env:ENGINE = 'docker' to use Docker instead of Podman.
param(
  [Parameter(Mandatory = $true, Position = 0)][string]$Command,
  [Parameter(Mandatory = $true, Position = 1)][string]$ProjectDir,
  [Parameter(ValueFromRemainingArguments = $true)][string[]]$Rest
)
$ErrorActionPreference = 'Stop'
if (-not $Rest) { $Rest = @() }

$Engine = if ($env:ENGINE) { $env:ENGINE } else { 'podman' }
$Image = 'localhost/lualatex-build'
# Helper images, pinned by digest so runs are repeatable.
$ScaffoldImage = 'docker.io/library/busybox@sha256:bd44eb136a95dcc8dc58995e43abc40a413f2e8e3d4a2aae6bccbe94686acb05'
$VeraImage = if ($env:VERAPDF_IMAGE) { $env:VERAPDF_IMAGE } else {
  'docker.io/verapdf/cli@sha256:d5ee329657cf9bc4b2400392dd54c7d0a0ce9980ff6fa2da5590eebeec007cdb' }
$Skill = Split-Path -Parent $PSScriptRoot

# Podman maps the caller's identity into the container. Docker Desktop on
# Windows needs no user mapping for files on Windows drives.
# @(...) keeps this an array even with one element; splatting a bare string
# would pass it to the engine character by character.
$UserArgs = @(if ($Engine -eq 'podman') { '--userns=keep-id' })

if ($Command -eq 'scaffold') {
  New-Item -ItemType Directory -Force -Path $ProjectDir | Out-Null
  $P = (Resolve-Path $ProjectDir).Path
  & $Engine run --rm @UserArgs -v "${Skill}:/skill:ro" -v "${P}:/work" $ScaffoldImage `
    sh /skill/scripts/scaffold.sh --dir /work @Rest
  exit $LASTEXITCODE
}

if (-not (Test-Path $ProjectDir)) { Write-Error "no project at $ProjectDir" }
$P = (Resolve-Path $ProjectDir).Path
if (-not (Test-Path (Join-Path $P 'Containerfile'))) { Write-Error "$P\Containerfile missing; run scaffold first" }
New-Item -ItemType Directory -Force -Path (Join-Path $P 'build') | Out-Null

# Rebuild the image every run; the layer cache makes an unchanged Containerfile
# take seconds. The first build pulls TeX Live (several GB).
$BuildLog = Join-Path (Join-Path $P 'build') 'image-build.log'
Write-Host 'image: building (log: build/image-build.log)'
& $Engine build -t $Image -f (Join-Path $P 'Containerfile') $P *> $BuildLog
if ($LASTEXITCODE -ne 0) {
  Get-Content $BuildLog -Tail 20
  Write-Error 'image build failed'
}

if ($Command -eq 'verapdf') {
  $Flavour = if ($Rest.Count -gt 0) { $Rest[0] } else { 'ua2' }
  if ($Flavour -notin @('ua1', 'ua2')) { Write-Error 'flavour must be ua1 or ua2' }
  Write-Host "verapdf: validating build/output.pdf as PDF/$Flavour"
  # veraPDF writes its own report inside the container, so no host redirect
  # (and no PowerShell text-encoding conversion) is involved.
  & $Engine run --rm -v "${P}:/work" --entrypoint sh $VeraImage -c `
    "/opt/verapdf/verapdf --flavour $Flavour --format xml /work/build/output.pdf > /work/build/verapdf.xml 2>/dev/null; exit 0"
  $Command = 'verapdf-report'
  $Rest = @()
}

& $Engine run --rm @UserArgs -e HOME=/tmp -v "${P}:/work" -w /work $Image `
  sh tools/latexctl $Command @Rest
exit $LASTEXITCODE
