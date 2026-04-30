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

# hai usage dashboard
alias get-usage="node /Users/I583713/hai-mcp-server/build/get-usage.js"
