#!/bin/zsh

##############################################################################
#
# User Configuration
# Note: See arch-specific configurations for more
#
##############################################################################

export ZSH_PROMPTS="$HOME/.zprompts"

if [ ! -d $ZSH_PROMPTS ]; then
	mkdir -p $ZSH_PROMPTS
fi

fpath=("$ZSH_PROMPTS" "$fpath[@]")

if [ -f "$ZSH_PROMPTS/prompt_powerlevel10k_setup" ]; then
    # Source installation
	powerlevel10k_dir="$HOME/Gits/powerlevel10k"
else
    # Package manager installation
    powerlevel10k_dir="/usr/share/zsh-theme-powerlevel10k"
fi

if [ -d $powerlevel10k_dir ]; then
    export POWERLEVEL9K_INSTALLATION_DIR=$powerlevel10k_dir
    source $POWERLEVEL9K_INSTALLATION_DIR/powerlevel10k.zsh-theme
fi

# Compilation flags
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

# You may need to manually set your language environment
export LANG="en_US.UTF-8"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='vim'
fi

# Quick function for initializing directories that should exist upon first
# configuration pass.
function dirinit()
{
    if [ -z $1 ]; then
        return
    fi

    if [ ! -d $1 ]; then
        mkdir -p $1
        # Zsh gets mad about outputting to stdout
        # echo Created directory $1
    fi
}

export PLUGGED="$HOME/.vim/plugged"
dirinit $PLUGGED

# Shortcuts to important files
export RC="$HOME/.zshrc"
export VI="$HOME/.vimrc"
export GI="$HOME/.gitconfig"

export TOOLS="$HOME/Toolchains"
dirinit $TOOLS

export SBOX="$HOME/Sandbox"
dirinit $SBOX

export APPS="$HOME/Applications"
dirinit $APPS

# For cloned repos that will not be edited
export GITS="$HOME/Gits"
dirinit $GITS

# For cloned repos that are forks or personal
export REPOS="$HOME/Repos"
dirinit $REPOS

export BIN="$HOME/bin"
dirinit $BIN

##############################################################################
#
# Rust
#
##############################################################################

export CARGO_ROOT_DIR="$HOME/.cargo"

if [ -f $CARGO_ROOT_DIR/bin/lsd ]; then
    export LS='lsd'
    alias l='$LS -al --group-dirs=first --date=+"%Y.%m.%d %H:%M:%S"'
    alias ll='$LS -alhX'
    alias lt='$LS --group-dirs=first --tree'

elif [ -f $CARGO_ROOT_DIR/bin/exa ]; then
    export LS='exa'
    alias l='$LS -al --group-directories-first'
    alias ll='l --git-ignore'
    alias lt='$LS --tree'

else
	export LS='ls'
	alias l='$LS -al --color=auto --group-directories-first'
	alias ll='l -h -X'
    alias lt='tree'

fi

if [ -f $CARGO_ROOT_DIR/bin/bat ]; then
    alias bat='bat --theme gruvbox-dark --color always'
    alias batty='bat --style plain'

    export BAT_PAGER="less -R"
    alias less='batty'
fi

if [ -f $CARGO_ROOT_DIR/bin/rg ]; then
        export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

if [ -f $CARGO_ROOT_DIR/bin/fd ]; then
    if [ -d $HOME/.fzf ]; then
        # Use fd as the default fuzzy finder
        export FZF_DEFAULT_COMMAND='fd -H -L --type f --no-ignore-vcs'
    fi
fi

##############################################################################
#
# General Aliases
# Note: See arch-specific configurations for more
#
##############################################################################

alias aliases='alias | less'
alias cp='cp -v'
alias cr='cp -r'
alias e='exit'
alias kiwf='kill -s SIGKILL' # kill it with fire
alias lesg='less +G'
alias lesn='less -n'
alias lns='ln -sf'
alias mkdirs='mkdir -p'
alias psme='ps -U $USERNAME -o "%U %p  %P (%r) %C " -o %mem -o " %t (" -o start_time -o ") %a"'
alias svi='sudo -e'
alias vi='$EDITOR'

##############################################################################
#
# Python
#
##############################################################################

export PYPI_URL="https://pypi.org/simple"

alias py='python3'
alias pipn='python3 -m pip install --user'
alias pun='python3 -m pip uninstall -y'
alias pyv='python3 -m venv'
alias pypi_upload_test='python3 -m twine upload --repository-url https://test.pypi.org/legacy/ dist/*'
alias pypi_upload='python3 -m twine upload dist/*'
alias pydev='python3 setup.py develop'
alias pydist='python3 setup.py sdist bdist_wheel'
alias showcoms='python3 -m serial.tools.list_ports -v'

function pyterm()
{
    python3 -m serial.tools.list_ports -v
    python3 -m serial.tools.miniterm --raw -
}

# Local venv within PWD
export VENV='venv'
alias va='source $VENV/bin/activate'
alias vd='deactivate'

# System placement of all non-local virtual environments
export PYBOX="$SBOX/python"
export PYVENV="$PYBOX/envs"
dirinit $PYVENV

export DEVENV="$PYVENV/devenv"
alias dva='source $DEVENV/bin/activate'

function rmdist
{
    if [ -f $CARGO_ROOT_DIR/bin/fd ]; then
        fd -I -t d "(egg-info|^build|^dist)" -d 3 -x sh -c "echo Removing {}; rm -r {}" \;
    else
        echo "Not yet defined for find."
    fi
}

##############################################################################
#
# Git
#
##############################################################################

export GBR='$(git rev-parse --abbrev-ref HEAD)'

alias gn='git number'
alias gst='gn --column' # This will show the same as "git status", but with numbers
alias gc='gn -c'
alias gvi='gc vim'
alias grm='gc rm'
alias gbr='git branch -v -r | cat'
alias gtl='git tag --list | cat'

function gbv()
{
    echo
    echo "Local branches:"
    echo

    PAGER= git branch -vv

    if [ -f $CARGO_ROOT_DIR/bin/rg ]; then
        grepper=rg
        grep_args=("-N" "--color=never")
    else
        grepper=grep
        grep_args=("-e")
    fi

    if [[ "$1" =~ "--me" ]]; then
        origin=""
    else
        origin="origin"
    fi

    remote_list="(${origin}"
    if [ ! -z $GIT_USER ]; then
        remote_list="${remote_list}|${GIT_USER}"
    fi
    remote_list="${remote_list})"

    echo
    echo "Remote branches for ${remote_list}:"
    echo
    git branch -rv | $grepper "${grep_args[@]}" "${remote_list}/"

    echo
    echo "Branches no longer in sync:"
    echo
    git branch -vv | $grepper $grep_args '(gone|ahead|behind)' | awk '{print $1}'
}

function gcl()
{
    git clone --depth 1 $@
}

function gpr ()
{
        remote=$1
        num=$2

        local_branch="pr-${num}"

        git b -D $local_branch 2> /dev/null
        git fetch $remote pull/$num/head:$local_branch
}

function gar()
{
    format=$1
    sha=$(git rev-parse --short HEAD)
    repo=$(basename "$PWD")
    name="${repo}-${sha}"

    echo "Archiving '${repo}' (SHA: ${sha}) as '${name}"
    git archive --format $format --prefix "${name}/" -o "${name}.zip" HEAD
}

# Fetch git repos relevant to me
function gfme {

if [[ "$1" =~ "-v" ]]; then
    verbose=-v
    shift
else
    verbose=
fi

remotes=(origin kyberdin)

if [ ! -z $verbose ]; then
    echo "Valid remotes:"
    echo "[$remotes]"
    echo
fi

for r in $(git remote show);
do
    if [[ ${remotes[(i)$r]} -le ${#remotes} ]] ; then
        echo "Fetching from remote '$r'"
        git fetch $verbose -p $r
    fi
done

}

##############################################################################
#
# SSH Keys and Keychain
#
##############################################################################

export SSH="$HOME/.ssh"
dirinit $SSH

export SSH_ROOT_KEY="$SSH/id_rsa"

alias keyup='eval $(ssh-agent -s)'

if [[ "$TERM" =~ "alacritty" ]]; then
    # Override TERM for SSH connections so it doesn't use alacritty, which
    # probably won't be known on the other terminal
    alias ssh='TERM=xterm-256color ssh'
fi

function add_to_keychain()
{
    idkey="$SSH/$1"
    if [ ! -f $idkey ]; then
        echo "No such key: $idkey"
        return
    fi

    if [ $macos -eq 1 ]; then
        # Inherit any existing SSH_AUTH_SOCK instead of a temporary one only
        # used by keychain
        eval `keychain --inherit any --eval $idkey`

        echo -n "Start a new SSH agent? [y/N]: "
        read -t 30 start
        if [[ $start =~ "Y" ]] || [[ $start =~ "y" ]]; then
            eval $(ssh-agent -s)
        fi

        # Add the key to the system keychain.
        # This is necessary for Sublime Merge to pick it up and use it.
        ssh-add -K $idkey
    else
        eval `keychain --eval $idkey`
    fi
}

##############################################################################
#
# Software (General)
#
##############################################################################

# Ensure GCC colors are activated in the terminal
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export BUILD_DIR='_build'
alias mkbuild='mkdir $BUILD_DIR && cd $BUILD_DIR'
alias rebuild='cd .. && rm -r $BUILD_DIR && mkdir $BUILD_DIR && cd $BUILD_DIR'

function rmbuild
{
    if [ -f $CARGO_ROOT_DIR/bin/fd ]; then
        fd -I -t d "(^build$|^_build.*$)" -d 1 -x sh -c "echo Removing {}; rm -r {}" \;
    else
        echo "Not yet defined for find."
    fi
}

if [ -f /usr/bin/ninja ]; then
    # Always use Ninja. ALWAYS. If you can't override as needed.
    export CMAKE_GENERATOR=Ninja
fi
