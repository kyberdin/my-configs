#!/bin/bash

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# enable git-branch coloring and appearance
parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
fi
unset color_prompt force_color_prompt

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='vim'
else
	export EDITOR='vim'
fi

alias upd='sudo apt update'
alias upg='sudo apt upgrade'
alias sai='sudo apt install'
alias sain='sudo apt install --no-install-recommends'
alias svi='sudo -e'
alias e='exit'
alias vi='$EDITOR'
alias aliases='alias | less'
alias psme='ps -U $USERNAME -o "%U %p  %P (%r) %C " -o %mem -o " %t (" -o start_time -o ") %a"'
alias kiwf='kill -s SIGKILL' # kill it with fire

alias l='ls -alhX --color=auto --group-directories-first'
alias mkdirs='mkdir -p'
alias cr='cp -rv'
alias lns='ln -s'
alias lesn='less -n'
alias lesg='lesn +G'
alias keyup='eval $(ssh-agent -s)'

if [ -f /usr/bin/xsel ]; then
	alias xb='xsel -bc && echo "Clipboard cleared."'
fi

alias pipn='python3 -m pip install --user'
alias pun='python3 -m pip uninstall -y'
alias showcoms='python3 -m serial.tools.list_ports -v'

# Local venv within PWD
export VENV='venv'
alias va='source $VENV/bin/activate'
alias vd='deactivate'

alias gn='git number'
alias gst='git number --column' # This will show the same as "git status", but with numbers
alias gc='gn -c'
alias gvi='gc vi'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if [ -f ~/.zsh_from_bash ]; then
	zsh
fi
