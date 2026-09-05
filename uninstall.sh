#!/usr/bin/env bash
#
# Remove the symlinks install.sh created, and restore the most recent backup
# it made at each path (if there is one).
#
# Only symlinks that point into this repo are touched — a real file at one of
# these paths is left completely alone. Plugins and Vim state are not deleted
# by default; pass --purge for that.
#
# Usage:
#   ./uninstall.sh            remove symlinks, restore backups
#   ./uninstall.sh --purge    also delete plugins and swap/backup/undo state
#   ./uninstall.sh --dry-run  print what would happen, change nothing
#
set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DRY_RUN=0
PURGE=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --purge)   PURGE=1 ;;
    *) printf 'unknown option: %s\n' "$arg" >&2; exit 2 ;;
  esac
done

say()  { printf '  %s\n' "$*"; }
step() { printf '\n==> %s\n' "$*"; }
run()  { if (( DRY_RUN )); then say "would: $*"; else "$@"; fi; }

# --- remove a symlink if (and only if) it points into this repo ---------------
unlink_if_ours() {
  local dest="$1"

  if [[ ! -L "$dest" ]]; then
    [[ -e "$dest" ]] && say "keep $dest (a real file, not our symlink)"
    return
  fi

  local target
  target="$(readlink "$dest")"
  if [[ "$target" != "$REPO"/* ]]; then
    say "keep $dest (points outside the repo: $target)"
    return
  fi

  say "rm   $dest"
  run rm -- "$dest"

  # Restore the newest backup we left at this path, if any.
  local newest
  newest="$(find "$(dirname -- "$dest")" -maxdepth 1 -name "$(basename -- "$dest").backup.*" 2>/dev/null | sort | tail -1)"
  if [[ -n "$newest" ]]; then
    say "restore $newest -> $dest"
    run mv -- "$newest" "$dest"
  fi
}

step "Uninstalling links into $REPO"
(( DRY_RUN )) && say "(dry run — nothing will change)"

step "Vim"
unlink_if_ours "$HOME/.vimrc"
if [[ -d "$HOME/.vim" ]]; then
  shopt -s nullglob dotglob
  for item in "$HOME"/.vim/*; do
    unlink_if_ours "$item"
  done
  shopt -u nullglob dotglob
fi

step "Neovim"
unlink_if_ours "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.vim"

step "Generated machine-local overrides"
LOCAL="$HOME/.vim/local.vim"
if [[ -f "$LOCAL" ]]; then
  say "keep $LOCAL (may contain your own settings — delete it by hand if you want it gone)"
fi

if (( PURGE )); then
  step "Purging plugins and Vim state"
  for d in "$HOME/.vim/plugged" "$HOME/.vim/autoload/plug.vim" \
           "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugged" \
           "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim" \
           "$HOME/.local/state/vim"; do
    if [[ -e "$d" ]]; then
      say "rm -rf $d"
      run rm -rf -- "$d"
    fi
  done
else
  step "Kept (use --purge to remove)"
  say "plugins:  ~/.vim/plugged, ~/.vim/autoload/plug.vim"
  say "state:    ~/.local/state/vim  (swap, backup, undo history)"
fi

# Clean up an empty ~/.vim so we don't leave a stray directory behind.
if [[ -d "$HOME/.vim" ]] && [[ -z "$(ls -A "$HOME/.vim" 2>/dev/null)" ]]; then
  say "rmdir ~/.vim (now empty)"
  run rmdir -- "$HOME/.vim"
fi

step "Done"
