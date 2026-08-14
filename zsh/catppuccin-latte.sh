# Catppuccin Latte palette for the shell — the single source of truth for zsh
# theming. Sourced (via ~/.local/state/dotfiles/zsh-generated.sh, written by
# scripts/apply-state.sh) so the prompt, fzf and any future tool read one
# flavour. Plain assignments, not exports: these are consumed inside the shell
# (prompt/functions), so there's no need to leak 26 colours into every child.
CTP_FLAVOUR="latte"

CTP_ROSEWATER="#dc8a78"
CTP_FLAMINGO="#dd7878"
CTP_PINK="#ea76cb"
CTP_MAUVE="#8839ef"
CTP_RED="#d20f39"
CTP_MAROON="#e64553"
CTP_PEACH="#fe640b"
CTP_YELLOW="#df8e1d"
CTP_GREEN="#40a02b"
CTP_TEAL="#179299"
CTP_SKY="#04a5e5"
CTP_SAPPHIRE="#209fb5"
CTP_BLUE="#1e66f5"
CTP_LAVENDER="#7287fd"
CTP_TEXT="#4c4f69"
CTP_SUBTEXT1="#5c5f77"
CTP_SUBTEXT0="#6c6f85"
CTP_OVERLAY2="#7c7f93"
CTP_OVERLAY1="#8c8fa1"
CTP_OVERLAY0="#9ca0b0"
CTP_SURFACE2="#acb0be"
CTP_SURFACE1="#bcc0cc"
CTP_SURFACE0="#ccd0da"
CTP_BASE="#eff1f5"
CTP_MANTLE="#e6e9ef"
CTP_CRUST="#dce0e8"

# fzf --color flags for this flavour (official catppuccin mapping). Composed
# into FZF_DEFAULT_OPTS alongside the keybindings in .zshrc.
CTP_FZF_COLORS="--color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39 --color=fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78 --color=marker:#7287fd,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39 --color=selected-bg:#bcc0cc --color=border:#9ca0b0,label:#4c4f69"
