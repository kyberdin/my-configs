
##############################################################################
#
# Zsh Backend Configurations
#
# Source: https://wiki.archlinux.org/title/Zsh
#
##############################################################################

zauto_config="$HOME/.zshrc.autocomplete.zsh"

# Load Zsh Autocomplete if the config file exists
if [ -f $zauto_config ]; then
	source $zauto_config
else
	autoload -Uz compinit
	compinit

	# Use arrow-key based auto-completion
	zstyle ':completion:*' menu select
	setopt COMPLETE_ALIASES
fi

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# Setup the prompt
autoload -Uz promptinit
promptinit
prompt walters

# Create a zkbd compatible hash;
# To add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char

if [ ! -f $zauto_config ]; then
	key[Up]="${terminfo[kcuu1]}"
	key[Down]="${terminfo[kcud1]}"
	key[Left]="${terminfo[kcub1]}"
	key[Right]="${terminfo[kcuf1]}"
	key[PageUp]="${terminfo[kpp]}"
	key[PageDown]="${terminfo[knp]}"
	key[Shift-Tab]="${terminfo[kcbt]}"

	[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
	[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
	[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
	[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
	[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
	[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
	[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete
fi

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

if [ ! -f $zauto_config ]; then
	# Enable history search
	autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
	zle -N up-line-or-beginning-search
	zle -N down-line-or-beginning-search

	[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
	[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search
fi

# [Ctrl-RightArrow] - move forward one word
bindkey -- '^[[1;5C' forward-word

# [Ctrl-LeftArrow] - move backward one word
bindkey -- '^[[1;5D' backward-word

# [Ctrl-Delete] - delete whole forward-word
bindkey -- '^[[3;5~' kill-word

# Extend the run-help (i.e. man(1)) alias to include zsh items
autoload -Uz run-help
(( ${+aliases[run-help]} )) && unalias run-help
alias help=run-help

# Enable editing command line in EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
[ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

setopt EXTENDED_HISTORY
unsetopt SHARE_HISTORY 		# Do not share history between terminals
setopt INC_APPEND_HISTORY 	# Immediately append command to history
setopt HIST_IGNORE_SPACE 	# Ignore commands starting with a space
setopt HIST_IGNORE_DUPS 	# Do not append to history if same as previous
setopt HIST_IGNORE_ALL_DUPS # Remove previous entry if matches current
setopt HIST_VERIFY 			# Don't execute hist cmd directly, but enter in line

unsetopt FLOW_CONTROL 	# Disable start/stop flow control characters (^S/^Q)
setopt ALWAYS_TO_END 	# Move cursor to end if successful autocomplete of word

setopt INTERACTIVE_COMMENTS # Allows comments in interactive shells

# Taken from oh-my-zsh/lib/functions.zsh
#
# Set environment variable "$1" to default value "$2" if "$1" is not yet defined.
#
# Arguments:
#    1. name - The env variable to set
#    2. val  - The default value
# Return value:
#    0 if the env variable exists, 3 if it was set
#
function env_default() {
    [[ ${parameters[$1]} = *-export* ]] && return 0
    export "$1=$2" && return 3
}

# Use less for the system default PAGER
env_default 'PAGER' 'less'
env_default 'LESS' '-R'

##############################################################################
#
# Basic Configurations
#
##############################################################################

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='vim'
fi

# Set asome basic necessity aliases
alias e='exit'
alias lns='ln -sf'
alias mkdirs='mkdir -p'
alias svi='sudo -e'
alias vi='$EDITOR'
alias aliases='alias | less'
alias keyup='eval $(ssh-agent -s)'

export LS='ls'
alias l='$LS -alhX --color=auto --group-directories-first'
alias ll='l'
