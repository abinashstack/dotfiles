# Shared shell config — sourced by both .zshrc and .bashrc

eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Colorful ls
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# --- Secrets from macOS Keychain ---
keychain_env() {
    local val
    val=$(security find-generic-password -a "$USER" -s "$1" -w 2>/dev/null) && export "$1"="$val"
}

keychain_env "OPENAI_API_KEY"
keychain_env "ANTHROPIC_API_KEY"
keychain_env "GITHUB_TOKEN"

# --- Aliases ---
# hai
alias get-usage="node /Users/I583713/hai-mcp-server/build/get-usage.js"

# Python
alias pyenv="python3 -m venv venv && source venv/bin/activate"
alias activate="source venv/bin/activate"

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
alias dots="cd ~/.dotfiles"

# Apps
alias chrome="open -a 'Google Chrome'"
alias brave="open -a 'Brave Browser'"
alias safari="open -a 'Safari'"
alias code="open -a 'Visual Studio Code'"
alias teams="open -a 'Microsoft Teams'"
alias excel="open -a 'Microsoft Excel'"
alias word="open -a 'Microsoft Word'"
alias ppt="open -a 'Microsoft PowerPoint'"
alias outlook="open -a 'Microsoft Outlook'"
alias finder="open ."

# Misc
alias cls="clear"
alias ip="curl -s ifconfig.me"
alias ports="lsof -i -P -n | grep LISTEN"

# --- Functions ---
# GitHub quick open
github() {
    case "$1" in
        abinashstack) open "https://github.com/abinashstack" ;;
        I583713)      open "https://github.tools.sap/I583713" ;;
        "")           open "https://github.com/abinashstack" ;;
        *)            open "https://github.com/$1" ;;
    esac
}
