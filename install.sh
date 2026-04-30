#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"

link() {
    local src="$1" dst="$2"
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        echo "Backing up $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    ln -s "$src" "$dst"
    echo "Linked $dst → $src"
}

# Shell
link "$DOTFILES/zsh/.zshrc"             "$HOME/.zshrc"
link "$DOTFILES/zsh/.zprofile"          "$HOME/.zprofile"

# Git
link "$DOTFILES/git/.gitconfig"         "$HOME/.gitconfig"

# Terminal
link "$DOTFILES/wezterm/.wezterm.lua"   "$HOME/.wezterm.lua"

# Prompt
mkdir -p "$HOME/.config"
link "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"

# GitHub CLI
mkdir -p "$HOME/.config/gh"
link "$DOTFILES/gh/config.yml"          "$HOME/.config/gh/config.yml"

echo ""
echo "All dotfiles linked."
