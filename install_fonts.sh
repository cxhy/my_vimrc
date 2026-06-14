#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./install_fonts.sh [options]

Install font files from this repository's fonts/ directory into the current
user's Linux font directory.

Options:
  --link      Install fonts as symlinks (default).
  --copy      Install fonts as plain file copies.
  --dry-run   Print actions without changing files.
  -h, --help  Show this help.
EOF
}

log() {
  printf '[my_vimrc-fonts] %s\n' "$*"
}

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[my_vimrc-fonts] DRY-RUN:'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi

  "$@"
}

unique_path() {
  local base="$1"
  local candidate="$base"
  local index=1

  while [[ -e "$candidate" || -L "$candidate" ]]; do
    candidate="${base}.${index}"
    index=$((index + 1))
  done

  printf '%s\n' "$candidate"
}

install_font_file() {
  local source="$1"
  local target="$FONT_TARGET_DIR/$(basename "$source")"
  local backup_path

  if [[ -d "$target" && ! -L "$target" ]]; then
    printf '[my_vimrc-fonts] ERROR: Font target exists as a directory: %s\n' "$target" >&2
    exit 1
  fi

  if [[ "$FONT_INSTALL_MODE" == "link" ]] && [[ -L "$target" ]]; then
    local source_real
    local target_real

    source_real="$(readlink -f "$source")" || source_real=""
    target_real="$(readlink -f "$target")" || target_real=""
    if [[ -n "$source_real" && "$source_real" == "$target_real" ]]; then
      log "$(basename "$source") already linked"
      return 0
    fi
  fi

  if [[ "$FONT_INSTALL_MODE" == "copy" ]] && [[ -f "$target" && ! -L "$target" ]] && cmp -s "$source" "$target"; then
    log "$(basename "$source") already copied"
    return 0
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    backup_path="$(unique_path "$target.backup-$BACKUP_STAMP")"
    if [[ "$FONT_INSTALL_MODE" == "link" || -L "$target" ]]; then
      run mv "$target" "$backup_path"
      log "Moved existing font to $backup_path"
    else
      run cp -a "$target" "$backup_path"
      log "Backed up existing font to $backup_path"
    fi
  fi

  if [[ "$FONT_INSTALL_MODE" == "link" ]]; then
    run ln -s "$source" "$target"
    log "Linked $(basename "$source")"
    return 0
  fi

  run cp -a "$source" "$target"
  log "Copied $(basename "$source")"
}

FONT_INSTALL_MODE="link"
DRY_RUN=0

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --link)
      FONT_INSTALL_MODE="link"
      ;;
    --copy)
      FONT_INSTALL_MODE="copy"
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf '[my_vimrc-fonts] ERROR: Unknown option: %s\n' "$1" >&2
      exit 1
      ;;
  esac
  shift
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
FONT_SOURCE_DIR="${FONT_SOURCE_DIR:-$SCRIPT_DIR/fonts}"
FONT_TARGET_DIR="${FONT_TARGET_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/fonts/my_vimrc}"
BACKUP_STAMP="${BACKUP_STAMP:-$(date +%Y%m%d-%H%M%S)}"

if [[ ! -d "$FONT_SOURCE_DIR" ]]; then
  log "No fonts directory found at $FONT_SOURCE_DIR"
  log "Create it and add .ttf, .otf, or .ttc files if you want local font installation"
  exit 0
fi

mapfile -d '' FONT_FILES < <(
  find "$FONT_SOURCE_DIR" -type f \
    \( -iname '*.ttf' -o -iname '*.otf' -o -iname '*.ttc' \) \
    -print0
)

if [[ "${#FONT_FILES[@]}" -eq 0 ]]; then
  log "No font files found in $FONT_SOURCE_DIR"
  log "Supported extensions: .ttf, .otf, .ttc"
  exit 0
fi

log "Installing ${#FONT_FILES[@]} font file(s) to $FONT_TARGET_DIR"
log "Install mode: $FONT_INSTALL_MODE"
run mkdir -p "$FONT_TARGET_DIR"

for font_file in "${FONT_FILES[@]}"; do
  install_font_file "$font_file"
done

if command -v fc-cache >/dev/null 2>&1; then
  run fc-cache -f "$FONT_TARGET_DIR"
  log "Font cache refreshed for $FONT_TARGET_DIR"
else
  log "fc-cache not found; restart your GUI session or install fontconfig if fonts are not visible"
fi

if command -v fc-match >/dev/null 2>&1; then
  log "Current monospace match: $(fc-match -f '%{family}\n' monospace | head -n 1)"
fi

log "Font installation complete"
