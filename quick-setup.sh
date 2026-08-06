#!/usr/bin/env bash
#
# quick-setup.sh — symlinks dotfiles components into place.
#
# Usage:
#   ./quick-setup.sh --all                install everything
#   ./quick-setup.sh zshrc nvim           install specific components
#   ./quick-setup.sh tmux kitty
#
# Components: zshrc, nvim, tmux, kitty
#
# Existing files/symlinks at the target are renamed to <target>.backup-<timestamp>.

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

usage() {
    cat <<EOF
Usage: $(basename "$0") [--all] [zshrc] [nvim] [tmux] [kitty]

Symlinks selected dotfiles components into place. Existing files are backed
up to <target>.backup-${TIMESTAMP} before being replaced.

You must pass --all or at least one component name.
EOF
    exit 1
}

# --- Argument parsing ---
DO_ZSHRC=0
DO_NVIM=0
DO_TMUX=0
DO_KITTY=0

[[ $# -eq 0 ]] && usage

if ! command -v brew >/dev/null; then
    echo "error: Homebrew is required but not installed." >&2
    echo "Install it from https://brew.sh and re-run." >&2
    exit 1
fi

ensure_brew() {
    local pkg="$1"
    if command -v "$pkg" >/dev/null; then
        echo "  ✓ $pkg already installed"
    else
        echo "  - installing $pkg via brew..."
        brew install "$pkg"
    fi
}

for arg in "$@"; do
    case "$arg" in
        --all)   DO_ZSHRC=1; DO_NVIM=1; DO_TMUX=1; DO_KITTY=1 ;;
        zshrc)   DO_ZSHRC=1 ;;
        nvim)    DO_NVIM=1 ;;
        tmux)    DO_TMUX=1 ;;
        kitty)   DO_KITTY=1 ;;
        -h|--help) usage ;;
        *) echo "Unknown argument: $arg" >&2; usage ;;
    esac
done

# --- Helpers ---
link_into_place() {
    local source="$1" target="$2"

    if [[ ! -e "$source" ]]; then
        echo "  ! source missing: $source — skipping" >&2
        return 1
    fi

    if [[ -L "$target" ]]; then
        local current
        current="$(readlink "$target")"
        if [[ "$current" == "$source" ]]; then
            echo "  ✓ $target already linked"
            return 0
        fi
        echo "  - $target points to $current — replacing"
        rm "$target"
    elif [[ -e "$target" ]]; then
        local backup="${target}.backup-${TIMESTAMP}"
        echo "  - $target exists — backing up to $backup"
        mv "$target" "$backup"
    fi

    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
    echo "  ✓ linked $target → $source"
}

# --- Components ---
setup_zshrc() {
    echo "[zshrc]"
    ensure_brew zoxide
    link_into_place "$DOTFILES/.zshrc" "$HOME/.zshrc"
}

setup_nvim() {
    echo "[nvim]"
    ensure_brew nvim
    # nvim-treesitter (main branch) compiles parsers with the tree-sitter CLI.
    # The `tree-sitter-cli` formula is the actual binary; plain `tree-sitter` is
    # library-only. The npm/cargo builds don't work on this glibc — use brew.
    ensure_brew tree-sitter-cli
    link_into_place "$DOTFILES/nvim" "$HOME/.config/nvim"

    echo "  - bootstrapping Lazy.nvim plugins (headless sync)..."
    nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5 || \
        echo "  ! Lazy sync exited non-zero — open nvim manually and run :Lazy sync"
}

setup_tmux() {
    echo "[tmux]"
    ensure_brew tmux

    # Config relies on tmux 3.x features (e.g. terminal-features, OSC 133).
    local tmux_major
    tmux_major="$(tmux -V | sed -nE 's/^tmux ([0-9]+).*/\1/p')"
    if [[ -z "$tmux_major" || "$tmux_major" -lt 3 ]]; then
        echo "  ! tmux $(tmux -V) is too old — config requires 3.x. Try: brew upgrade tmux" >&2
        return 1
    fi

    link_into_place "$DOTFILES/tmux" "$HOME/.config/tmux"

    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [[ ! -d "$tpm_dir" ]]; then
        echo "  - cloning tpm into $tpm_dir"
        git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm_dir"
    else
        echo "  ✓ tpm already present"
    fi

    if [[ -x "$tpm_dir/scripts/install_plugins.sh" ]]; then
        echo "  - installing tmux plugins via tpm..."
        "$tpm_dir/scripts/install_plugins.sh" || \
            echo "  ! tpm install exited non-zero — start tmux and press prefix+I"
    fi
}

setup_kitty() {
    echo "[kitty]"
    link_into_place "$DOTFILES/kitty" "$HOME/.config/kitty"
}

# Machine-local state (theme flavour, kitty padding). kitty.conf and tmux.conf
# include generated files from the state dir, so these must exist before either
# starts cleanly. Existing state is preserved — this only fills in defaults.
setup_state() {
    echo "[state]"
    local summary
    summary="$("$DOTFILES/scripts/apply-state.sh")"
    echo "  ✓ generated $HOME/.local/state/dotfiles ($summary)"
}

# --- Run ---
echo "dotfiles: $DOTFILES"
echo

(( DO_ZSHRC )) && setup_zshrc
(( DO_NVIM ))  && setup_nvim
(( DO_TMUX ))  && setup_tmux
(( DO_KITTY )) && setup_kitty
# After the symlinks: the generated files reference ~/.config/{kitty,tmux}.
(( DO_TMUX || DO_KITTY || DO_NVIM )) && setup_state

echo
echo "done."
