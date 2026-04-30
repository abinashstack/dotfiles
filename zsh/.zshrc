eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/.local/bin:$PATH"

# Starship prompt
eval "$(starship init zsh)"

# Colorful ls
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Syntax highlighting (if installed)
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Auto-suggestions (if installed)
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
export PATH="$HOME/bin:$PATH"

# --- Secrets from macOS Keychain ---
# Usage: Add secrets with:
#   security add-generic-password -a "$USER" -s "ENV_VAR_NAME" -w "secret_value"
# They'll auto-load on every new shell.

keychain_env() {
    local val
    val=$(security find-generic-password -a "$USER" -s "$1" -w 2>/dev/null) && export "$1"="$val"
}

# Add your env vars here (keys stored in Keychain, not in this file)
keychain_env "OPENAI_API_KEY"
keychain_env "ANTHROPIC_API_KEY"
keychain_env "GITHUB_TOKEN"

# hai usage dashboard
alias get-usage="node /Users/I583713/hai-mcp-server/build/get-usage.js"

# --- Shortcuts ---
# Python
alias pyenv="python3 -m venv venv && source venv/bin/activate"
alias activate="source venv/bin/activate"
alias deactivate="deactivate"

# Git
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline -10"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -la"
alias la="ls -A"

# Dev servers
alias serve="python3 -m http.server 8000"
alias nr="npm run"
alias nrd="npm run dev"

# Quick open
alias zshrc="$EDITOR ~/.zshrc"
alias dots="cd ~/.dotfiles"

# Apps
alias chrome="open -a 'Google Chrome'"
alias brave="open -a 'Brave Browser'"
alias safari="open -a 'Safari'"
alias code="open -a 'Visual Studio Code'"
alias finder="open ."

# Misc
alias cls="clear"
alias ip="curl -s ifconfig.me"
alias ports="lsof -i -P -n | grep LISTEN"

# GitHub quick open
github() {
    case "$1" in
        abinashstack) open "https://github.com/abinashstack" ;;
        I583713)      open "https://github.tools.sap/I583713" ;;
        "")           open "https://github.com/abinashstack" ;;
        *)            open "https://github.com/$1" ;;
    esac
}

# WezTerm theme switcher (interactive with arrow keys)
theme() {
    local wez="$HOME/.dotfiles/wezterm/.wezterm.lua"
    local themes=(
        "Catppuccin Mocha"
        "Catppuccin Latte"
        "Catppuccin Frappe"
        "Catppuccin Macchiato"
        "Tokyo Night"
        "Tokyo Night Storm"
        "Dracula"
        "Gruvbox Dark"
        "Gruvbox Light"
        "Nord"
        "Solarized Dark"
        "Solarized Light"
        "One Dark (Gogh)"
        "Kanagawa (Gogh)"
        "rose-pine"
        "rose-pine-moon"
    )

    local selected=1
    local total=${#themes[@]}
    local key

    # Hide cursor
    tput civis
    trap 'tput cnorm' EXIT INT TERM

    # Draw menu
    _theme_draw() {
        clear
        print -P "%B Select a theme (↑/↓ to navigate, Enter to select, q to quit):%b"
        echo ""
        for i in {1..$total}; do
            if [ "$i" -eq "$selected" ]; then
                print -P "  %F{cyan}%B▸ ${themes[$i]}%b%f"
            else
                echo "    ${themes[$i]}"
            fi
        done
    }

    _theme_draw

    while true; do
        read -rsk1 key
        case "$key" in
            $'\e')
                read -rsk1 key
                read -rsk1 key
                case "$key" in
                    A) # Up arrow
                        ((selected--))
                        [ "$selected" -lt 1 ] && selected=$total
                        ;;
                    B) # Down arrow
                        ((selected++))
                        [ "$selected" -gt "$total" ] && selected=1
                        ;;
                esac
                ;;
            $'\n') # Enter
                break
                ;;
            q|Q)
                tput cnorm
                trap - EXIT INT TERM
                clear
                echo "Cancelled."
                return
                ;;
        esac
        _theme_draw
    done

    tput cnorm
    trap - EXIT INT TERM
    clear

    local chosen="${themes[$selected]}"
    sed -i '' "s/config.color_scheme = \".*\"/config.color_scheme = \"$chosen\"/" "$wez"
    echo "Theme changed to: $chosen"
}
