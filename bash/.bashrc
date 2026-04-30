# Source shared config (works in both bash and zsh)
source "$HOME/.dotfiles/shell/aliases.sh"

# --- Bash-specific ---
eval "$(starship init bash)"

alias bashrc="$EDITOR ~/.bashrc"

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

    local selected=0
    local total=${#themes[@]}
    local key

    tput civis
    trap 'tput cnorm' EXIT INT TERM

    _theme_draw() {
        clear
        echo -e "\033[1m Select a theme (↑/↓ to navigate, Enter to select, q to quit):\033[0m"
        echo ""
        for i in "${!themes[@]}"; do
            if [ "$i" -eq "$selected" ]; then
                echo -e "  \033[1;36m▸ ${themes[$i]}\033[0m"
            else
                echo "    ${themes[$i]}"
            fi
        done
    }

    _theme_draw

    while true; do
        read -rsn1 key
        case "$key" in
            $'\x1b')
                read -rsn2 key
                case "$key" in
                    '[A') ((selected--)); [ "$selected" -lt 0 ] && selected=$((total-1)) ;;
                    '[B') ((selected++)); [ "$selected" -ge "$total" ] && selected=0 ;;
                esac
                ;;
            '') break ;;
            q|Q)
                tput cnorm; trap - EXIT INT TERM; clear
                echo "Cancelled."; return ;;
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
