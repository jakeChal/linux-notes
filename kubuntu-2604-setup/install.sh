#!/bin/bash
# install.sh — bring up the terminal environment described in setup.md
#
# This script is intentionally simple: it installs apt packages, sets up
# Oh My Zsh + plugins + Powerlevel10k if missing, and symlinks dotfiles from
# configs/ into $HOME. Re-run safely; existing symlinks are replaced.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$REPO_DIR/configs"

echo "==> Installing apt packages"
sudo apt update
sudo apt install -y \
  yakuake tmux zsh git curl \
  fzf fd-find bat eza zoxide tldr wl-clipboard

echo "==> Setting up fd symlink (Debian ships fdfind)"
mkdir -p ~/.local/bin
if command -v fdfind >/dev/null && [ ! -e ~/.local/bin/fd ]; then
  ln -sf "$(command -v fdfind)" ~/.local/bin/fd
fi

echo "==> Installing MesloLGS NF (Powerlevel10k font)"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if [ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]; then
  cd "$FONT_DIR"
  for f in Regular Bold Italic "Bold%20Italic"; do
    wget -q "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${f}.ttf" \
      -O "MesloLGS NF $(echo $f | sed 's/%20/ /g').ttf"
  done
  fc-cache -f
  cd - >/dev/null
fi

echo "==> Installing Oh My Zsh (if missing)"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "==> Installing Powerlevel10k (if missing)"
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k"
fi

echo "==> Installing zsh plugins (if missing)"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

echo "==> Symlinking dotfiles"
for f in .zshrc .tmux.conf; do
  target="$HOME/$f"
  src="$CONFIG_DIR/$f"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "    Backing up existing $target -> $target.bak"
    mv "$target" "$target.bak"
  fi
  ln -sf "$src" "$target"
  echo "    $target -> $src"
done

echo "==> Setting vim as default git editor"
git config --global core.editor "vim"

echo ""
echo "==> Done."
echo "Next steps:"
echo "  chsh -s \$(which zsh)   (log out/in afterwards)"
