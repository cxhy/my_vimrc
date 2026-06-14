#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Install this repository's Vim and Git configuration into the current user's
home directory.

Options:
  --link            Install config files as symlinks (default).
  --copy            Install config files as plain file copies.
  --install-fonts   Link font files from fonts/ into the user font directory.
  --skip-vim-plug   Do not install ~/.vim/autoload/plug.vim.
  --skip-plugins    Do not run Vim PlugInstall.
  --dry-run         Print actions without changing files.
  -h, --help        Show this help.
EOF
}

log() {
  printf '[my_vimrc] %s\n' "$*"
}

die() {
  printf '[my_vimrc] ERROR: %s\n' "$*" >&2
  exit 1
}

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[my_vimrc] DRY-RUN:'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi

  "$@"
}

report_action() {
  local done_message="$1"
  local dry_run_message="$2"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "$dry_run_message"
    return 0
  fi

  log "$done_message"
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

ensure_backup_dir() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi

  mkdir -p "$BACKUP_DIR"
}

backup_existing() {
  local target="$1"
  local label="$2"
  local backup_path

  if [[ ! -e "$target" && ! -L "$target" ]]; then
    log "No existing $target to back up"
    return 0
  fi

  backup_path="$(unique_path "$BACKUP_DIR/$label")"
  run cp -a "$target" "$backup_path"
  report_action \
    "Backed up $target to $backup_path" \
    "Would back up $target to $backup_path"
}

move_existing_to_backup() {
  local target="$1"
  local label="$2"
  local moved_path

  if [[ ! -e "$target" && ! -L "$target" ]]; then
    return 0
  fi

  moved_path="$(unique_path "$BACKUP_DIR/${label}.replaced")"
  run mv "$target" "$moved_path"
  report_action \
    "Moved existing $target to $moved_path" \
    "Would move existing $target to $moved_path"
}

is_expected_symlink() {
  local source="$1"
  local target="$2"
  local source_real
  local target_real

  [[ -L "$target" ]] || return 1

  source_real="$(readlink -f "$source")" || return 1
  target_real="$(readlink -f "$target")" || return 1
  [[ "$source_real" == "$target_real" ]]
}

is_same_regular_file() {
  local source="$1"
  local target="$2"

  [[ -f "$target" && ! -L "$target" ]] || return 1
  cmp -s "$source" "$target"
}

install_config() {
  local source="$1"
  local target="$2"
  local label="$3"

  [[ -f "$source" ]] || die "Required source file is missing: $source"

  if [[ "$INSTALL_MODE" == "link" ]] && is_expected_symlink "$source" "$target"; then
    log "$target already points to $source"
    return 0
  fi

  if [[ "$INSTALL_MODE" == "copy" ]] && is_same_regular_file "$source" "$target"; then
    log "$target already matches $source"
    return 0
  fi

  backup_existing "$target" "$label"

  if [[ "$INSTALL_MODE" == "link" ]]; then
    move_existing_to_backup "$target" "$label"
    run ln -s "$source" "$target"
    report_action \
      "Linked $target -> $source" \
      "Would link $target -> $source"
    return 0
  fi

  if [[ -L "$target" ]]; then
    move_existing_to_backup "$target" "$label"
  fi

  run cp "$source" "$target"
  report_action \
    "Copied $source to $target" \
    "Would copy $source to $target"
}

install_vim_plug() {
  local plug_target="$HOME/.vim/autoload/plug.vim"
  local plug_dir
  local plug_url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

  if [[ "$SKIP_VIM_PLUG" -eq 1 ]]; then
    log "Skipping vim-plug installation"
    return 0
  fi

  if [[ -e "$plug_target" ]]; then
    log "vim-plug already exists at $plug_target"
    return 0
  fi

  if [[ -L "$plug_target" ]]; then
    backup_existing "$plug_target" "plug.vim"
    move_existing_to_backup "$plug_target" "plug.vim"
  fi

  plug_dir="$(dirname "$plug_target")"
  run mkdir -p "$plug_dir"

  if [[ -f "$VENDORED_PLUG" ]]; then
    run cp "$VENDORED_PLUG" "$plug_target"
    report_action \
      "Installed vim-plug from $VENDORED_PLUG to $plug_target" \
      "Would install vim-plug from $VENDORED_PLUG to $plug_target"
    return 0
  fi

  if command -v curl >/dev/null 2>&1; then
    run curl -fLo "$plug_target" "$plug_url"
    report_action \
      "Downloaded vim-plug to $plug_target" \
      "Would download vim-plug to $plug_target"
    return 0
  fi

  if command -v wget >/dev/null 2>&1; then
    run wget -O "$plug_target" "$plug_url"
    report_action \
      "Downloaded vim-plug to $plug_target" \
      "Would download vim-plug to $plug_target"
    return 0
  fi

  die "vim-plug is missing and neither curl nor wget is available"
}

install_plugins() {
  local vimrc_target="$HOME/.vimrc"
  local source_cmd

  if [[ "$SKIP_PLUGINS" -eq 1 ]]; then
    log "Skipping Vim plugin installation"
    return 0
  fi

  if ! command -v vim >/dev/null 2>&1; then
    die "vim executable not found; install Vim or rerun with --skip-plugins"
  fi

  source_cmd="+execute 'silent! source' fnameescape('$vimrc_target')"
  log "Installing Vim plugins with PlugInstall"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    run vim -Nu NONE -n "+set nomore" "$source_cmd" "+PlugInstall --sync" +qa
    return 0
  fi

  if ! vim -Nu NONE -n "+set nomore" "$source_cmd" "+PlugInstall --sync" +qa; then
    die "Vim PlugInstall failed"
  fi

  log "Vim plugin installation completed"
}

install_fonts() {
  local font_script="$REPO_ROOT/install_fonts.sh"
  local font_args=(--link)

  if [[ "$INSTALL_FONTS" -eq 0 ]]; then
    return 0
  fi

  [[ -f "$font_script" ]] || die "Font installer is missing: $font_script"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    font_args+=(--dry-run)
  fi

  log "Installing user fonts"
  bash "$font_script" "${font_args[@]}"
}

INSTALL_MODE="link"
INSTALL_FONTS=0
SKIP_VIM_PLUG=0
SKIP_PLUGINS=0
DRY_RUN=0

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --link)
      INSTALL_MODE="link"
      ;;
    --copy)
      INSTALL_MODE="copy"
      ;;
    --install-fonts)
      INSTALL_FONTS=1
      ;;
    --skip-vim-plug)
      SKIP_VIM_PLUG=1
      ;;
    --skip-plugins)
      SKIP_PLUGINS=1
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
  shift
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
REPO_ROOT="$SCRIPT_DIR"
VIMRC_SOURCE="$REPO_ROOT/vimrc"
GITCONFIG_SOURCE="$REPO_ROOT/gitconfig"
GITIGNORE_SOURCE="$REPO_ROOT/gitignore_global"
VENDORED_PLUG="$REPO_ROOT/autoload/plug.vim"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.config_backup/my_vimrc}"
BACKUP_STAMP="${BACKUP_STAMP:-$(date +%Y%m%d-%H%M%S)}"
BACKUP_DIR="$(unique_path "$BACKUP_ROOT/$BACKUP_STAMP")"

log "Repository root: $REPO_ROOT"
log "Install mode: $INSTALL_MODE"
ensure_backup_dir
log "Backup directory: $BACKUP_DIR"

install_config "$VIMRC_SOURCE" "$HOME/.vimrc" ".vimrc"
install_config "$GITCONFIG_SOURCE" "$HOME/.gitconfig" ".gitconfig"
install_config "$GITIGNORE_SOURCE" "$HOME/.gitignore_global" ".gitignore_global"
install_fonts
install_vim_plug
install_plugins

log "Installation complete"
