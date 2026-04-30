# dotfiles

My macOS development environment.

## Setup (fresh machine)

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Clone
git clone https://github.com/abinashstack/dotfiles.git ~/.dotfiles

# 3. Install tools
brew bundle --file=~/.dotfiles/Brewfile

# 4. Link configs
~/.dotfiles/install.sh
```

## What's tracked

| Tool       | Config                |
| ---------- | --------------------- |
| Zsh        | `.zshrc`, `.zprofile` |
| Git        | `.gitconfig`          |
| Starship   | `starship.toml`       |
| WezTerm    | `.wezterm.lua`        |
| GitHub CLI | `config.yml`          |
| Homebrew   | `Brewfile`            |

## Adding a new config

1. Move the file into the appropriate directory under `~/.dotfiles/`
2. Add a `link` line to `install.sh`
3. Re-run `./install.sh`
