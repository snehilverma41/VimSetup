#!/usr/bin/env bash
# Shell setup for a new macOS machine: oh-my-zsh + powerlevel10k,
# zsh plugins, and CLI tools.
# Safe to re-run: finished steps are skipped.
set -euo pipefail

step() { printf '\n==> %s\n' "$*"; }

if ! command -v brew >/dev/null; then
  echo "Homebrew is required: https://brew.sh" >&2
  exit 1
fi
BREW_PREFIX="$(brew --prefix)"

step "oh-my-zsh"
# --unattended: don't chsh or drop into a new zsh at the end, which would stall
# the script. An existing ~/.zshrc is moved to ~/.zshrc.pre-oh-my-zsh.
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

step "powerlevel10k"
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi
sed -i '' 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"

step "MesloLGS NF fonts"
# Without these the prompt icons render as boxes.
# https://github.com/romkatv/powerlevel10k#fonts
for style in Regular Bold Italic "Bold Italic"; do
  font="$HOME/Library/Fonts/MesloLGS NF $style.ttf"
  if [[ ! -f "$font" ]]; then
    curl -fsSL -o "$font" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${style// /%20}.ttf"
  fi
done

step "Homebrew packages"
brew install \
  zsh-syntax-highlighting \
  zsh-autosuggestions \
  zsh-completions \
  fzf

step "~/.zshrc plugin config"
MARKER='# >>> shell-setup-oss >>>'
if ! grep -qF "$MARKER" "$HOME/.zshrc"; then
  cat >>"$HOME/.zshrc" <<EOF

$MARKER
# Default is fg=8 (ANSI "bright black"), which equals the background in this
# color scheme and makes suggestions invisible. base01 is Solarized's "comment"
# grey: clearly readable, but clearly dimmer than typed text (base0).
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#586e75'
source $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

FPATH=$BREW_PREFIX/share/zsh-completions:\$FPATH
autoload -Uz compinit
compinit

# fzf key bindings (Ctrl-R history, Ctrl-T files) and ** completion
source <(fzf --zsh)

# Must be sourced last, after compinit and any other widgets.
source $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# <<< shell-setup-oss <<<
EOF
fi

cat <<'EOF'

Done. Remaining manual steps:
  1. Set your terminal font to "MesloLGS NF".
  2. Open a new terminal. The powerlevel10k wizard starts on its own
     (rerun later with `p10k configure`).
EOF
