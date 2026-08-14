# source ~/.dir_aliases

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	macos
	github
)

source $ZSH/oh-my-zsh.sh

# ── Catppuccin theme (prompt + fzf), driven by machine-local state ───────────
# scripts/apply-state.sh writes ~/.local/state/dotfiles/zsh-generated.sh, which
# sources the selected flavour's palette (zsh/catppuccin-<flavour>.sh) and so
# defines CTP_* colours + CTP_FZF_COLORS. toggle-theme.sh regenerates that file
# and signals running shells (USR1) to re-source it live. Must come after
# oh-my-zsh.sh, which is where the theme first assigns PROMPT.
_ctp_generated="$HOME/.local/state/dotfiles/zsh-generated.sh"

# fzf keybindings live here (portable) so the flavour's colours and the binds
# compose into one FZF_DEFAULT_OPTS; keeping them separate lets a live retheme
# rebuild the colours without losing the binds.
_ctp_fzf_binds="--bind 'alt-j:down,alt-k:up,alt-h:backward-char,alt-l:forward-char' --bind 'ctrl-d:half-page-down,ctrl-u:half-page-up' --bind 'ctrl-f:page-down,ctrl-b:page-up'"
_ctp_apply_fzf() { export FZF_DEFAULT_OPTS="${CTP_FZF_COLORS:-} ${_ctp_fzf_binds}" }

# The prompt is rebuilt from scratch (not prepended to) so a live retheme never
# accumulates the OSC 133 prefix. 133;A must be part of PROMPT, not emitted from
# a precmd hook: tmux records the marker against a grid line, and ZLE redraws the
# prompt line after precmd, wiping anything written there first. %{...%} keeps it
# zero-width. %F{#hex} is already non-printing to zsh, so it needs no wrapper.
_ctp_apply_prompt() {
  local osc133=""
  [[ $TERM != "dumb" ]] && osc133="%{"$'\e]133;A\a'"%}"
  if [[ -n ${CTP_FLAVOUR:-} ]]; then
    PROMPT="${osc133}%(?:%F{$CTP_GREEN}%1{➜%} :%F{$CTP_RED}%1{➜%} ) %F{$CTP_TEAL}%c%f "
    PROMPT+='$(git_prompt_info)'
    ZSH_THEME_GIT_PROMPT_PREFIX="%F{$CTP_BLUE}git:(%F{$CTP_RED}"
    ZSH_THEME_GIT_PROMPT_SUFFIX="%f "
    ZSH_THEME_GIT_PROMPT_DIRTY="%F{$CTP_BLUE}) %F{$CTP_YELLOW}%1{✗%}"
    ZSH_THEME_GIT_PROMPT_CLEAN="%F{$CTP_BLUE})"
  else
    # Palette not generated yet — keep oh-my-zsh's prompt, just add the marker.
    PROMPT="${osc133}${PROMPT}"
  fi
}

_ctp_reload() {
  [[ -r "$_ctp_generated" ]] && source "$_ctp_generated"
  _ctp_apply_fzf
  _ctp_apply_prompt
  # Redraw immediately if we're sitting at the line editor.
  zle && zle reset-prompt
}

[[ -r "$_ctp_generated" ]] && source "$_ctp_generated"
_ctp_apply_fzf
_ctp_apply_prompt

# 133;C marks where command output begins, which is what previous-prompt -o
# homes in on in tmux copy-mode.
if [[ $TERM != "dumb" ]]; then
  autoload -Uz add-zsh-hook
  _osc133_preexec() { print -Pn $'\e]133;C\a' }
  add-zsh-hook preexec _osc133_preexec
fi

# Live retheme: register this shell's pid so toggle-theme.sh signals only shells
# that have the USR1 trap installed. SIGUSR1's default action is to terminate,
# so a blanket signal would kill any zsh (script or pre-change shell) without the
# trap — the pidfile is the opt-in that makes the push safe.
if [[ -o interactive ]]; then
  TRAPUSR1() { _ctp_reload }
  _ctp_pid_dir="$HOME/.local/state/dotfiles/zsh-pids"
  mkdir -p "$_ctp_pid_dir" && : > "$_ctp_pid_dir/$$"
  autoload -Uz add-zsh-hook
  _ctp_unregister() { rm -f "$_ctp_pid_dir/$$" }
  add-zsh-hook zshexit _ctp_unregister
fi

# Report the running command to tmux's status line via a per-pane option.
# preexec fires with the full command line before it runs; precmd marks it done
# once the command returns. Writing straight to a tmux option sidesteps PTY
# wrappers (e.g. kiro-cli-term) that hide the real process from pane_current_command.
# Two command options are stored: @pane_cmd_raw keeps real newlines (for copying
# the command exactly as typed) while @pane_cmd renders them as literal "\n" so
# the single-line status bar shows multi-line commands on one line.
# @pane_cmd_running drives the status-line color (teal running, grey completed).
if [[ -n "$TMUX" && -n "$TMUX_PANE" ]]; then
  autoload -Uz add-zsh-hook
  _tmux_panecmd_preexec() {
    tmux set -p -t "$TMUX_PANE" @pane_cmd_raw "$1" \; \
         set -p -t "$TMUX_PANE" @pane_cmd "${1//$'\n'/\\n}" \; \
         set -p -t "$TMUX_PANE" @pane_cmd_running 1 2>/dev/null
  }
  _tmux_panecmd_precmd()  { tmux set -p -t "$TMUX_PANE" @pane_cmd_running 0 2>/dev/null }
  add-zsh-hook preexec _tmux_panecmd_preexec
  add-zsh-hook precmd _tmux_panecmd_precmd
fi

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias tma="tmux attach"

eval "$(zoxide init --cmd cd zsh)"

# echo ""
# echo "Tmux windows:"
# echo "$(tmux ls)"
# . "$HOME/.cargo/env"

# if [[ -n "$TMUX" ]] then
#   export flavor='conda'
#   source $HOME/.config/tmux/plugins/tmux-conda-inherit/conda-inherit.sh
# fi

export PYTHONPATH=$PYTHONPATH:/Users/edwardbirchall/Library/CloudStorage/OneDrive-ZuluForestLtd/1Drive/shared-python-scripts
export DYLD_FALLBACK_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_FALLBACK_LIBRARY_PATH"


# venv wrapper (https://gist.github.com/benlubas/5b5e38ae27d9bb8b5c756d8371e238e6)
# usage
# $ mkvenv myvirtualenv # creates venv under ~/.virtualenvs/
# $ venv myvirtualenv   # activates venv
# $ deactivate          # deactivates venv
# $ rmvenv myvirtualenv # removes venv

export VENV_HOME="$HOME/.virtualenvs"
[[ -d $VENV_HOME ]] || mkdir $VENV_HOME

lsvenv() {
  ls -1 $VENV_HOME
}

venv() {
  if [ $# -eq 0 ]
    then
      echo "Please provide venv name"
    else
      source "$VENV_HOME/$1/bin/activate"
  fi
}

mkvenv() {
  if [ $# -eq 0 ]
    then
      echo "Please provide venv name"
    else
      python3 -m venv $VENV_HOME/$1
  fi
}

rmvenv() {
  if [ $# -eq 0 ]
    then
      echo "Please provide venv name"
    else
      rm -r $VENV_HOME/$1
  fi
}

skim() {
  if [ $# -eq 0 ]
    then 
      open skim://
    else
      abs_path=$(realpath "$1")
      echo "Opening" $abs_path
      open skim://$abs_path
  fi
}

# source ~/.beerme/beerme.sh
