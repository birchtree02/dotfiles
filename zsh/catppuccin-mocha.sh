# Catppuccin Mocha palette for the shell — the single source of truth for zsh
# theming. Sourced (via ~/.local/state/dotfiles/zsh-generated.sh, written by
# scripts/apply-state.sh) so the prompt, fzf and any future tool read one
# flavour. Plain assignments, not exports: these are consumed inside the shell
# (prompt/functions), so there's no need to leak 26 colours into every child.
CTP_FLAVOUR="mocha"

CTP_ROSEWATER="#f5e0dc"
CTP_FLAMINGO="#f2cdcd"
CTP_PINK="#f5c2e7"
CTP_MAUVE="#cba6f7"
CTP_RED="#f38ba8"
CTP_MAROON="#eba0ac"
CTP_PEACH="#fab387"
CTP_YELLOW="#f9e2af"
CTP_GREEN="#a6e3a1"
CTP_TEAL="#94e2d5"
CTP_SKY="#89dceb"
CTP_SAPPHIRE="#74c7ec"
CTP_BLUE="#89b4fa"
CTP_LAVENDER="#b4befe"
CTP_TEXT="#cdd6f4"
CTP_SUBTEXT1="#bac2de"
CTP_SUBTEXT0="#a6adc8"
CTP_OVERLAY2="#9399b2"
CTP_OVERLAY1="#7f849c"
CTP_OVERLAY0="#6c7086"
CTP_SURFACE2="#585b70"
CTP_SURFACE1="#45475a"
CTP_SURFACE0="#313244"
CTP_BASE="#1e1e2e"
CTP_MANTLE="#181825"
CTP_CRUST="#11111b"

# fzf --color flags for this flavour (official catppuccin mapping). Composed
# into FZF_DEFAULT_OPTS alongside the keybindings in .zshrc.
CTP_FZF_COLORS="--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --color=selected-bg:#45475a --color=border:#6c7086,label:#cdd6f4"
