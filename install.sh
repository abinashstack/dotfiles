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

# Shell — Zsh
link "$DOTFILES/zsh/.zshrc"             "$HOME/.zshrc"
link "$DOTFILES/zsh/.zprofile"          "$HOME/.zprofile"

# Shell — Bash
link "$DOTFILES/bash/.bashrc"           "$HOME/.bashrc"
link "$DOTFILES/bash/.bash_profile"     "$HOME/.bash_profile"

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

# Network watchdog
mkdir -p "$HOME/Library/LaunchAgents"
mkdir -p "$HOME/Library/Logs"
link "$DOTFILES/launchd/com.abinash.network-watchdog.plist" \
     "$HOME/Library/LaunchAgents/com.abinash.network-watchdog.plist"
chmod +x "$DOTFILES/scripts/network-watchdog.sh"

echo ""
echo "All dotfiles linked."
echo ""

# Load network watchdog (skip if already loaded)
if ! launchctl list 2>/dev/null | grep -q "com.abinash.network-watchdog"; then
    launchctl load "$HOME/Library/LaunchAgents/com.abinash.network-watchdog.plist" 2>/dev/null
    echo "Loaded network-watchdog LaunchAgent"
else
    echo "network-watchdog already loaded"
fi
