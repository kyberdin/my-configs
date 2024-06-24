#!/bin/zsh
#
# DO NOT SOURCE THIS FILE BEFORE ~/.zshrc
#

# Currently supported flavors are Debian/Ubuntu and ArchLinux
debian=0
if [[ $(uname -v) =~ "Ubuntu" ]]; then
    debian=1
fi


##############################################################################
#
# User Configuration
#
##############################################################################

# Keep disabled for now
# export ARCHFLAGS="-arch x86_64"

export USB="/media/$USER"

alias xb='xsel -bc && echo "Clipboard cleared."'
alias srm='srm -v'

if [ $debian -eq 1 ]; then
    alias upd='sudo apt update'
    alias upg='sudo apt upgrade'
    alias supg='upd && upg'
    alias sai='sudo apt install'
    alias sain='sudo apt install --no-install-recommends'
    alias aptl='apt list --upgradable'

    if [ -f $CARGO_ROOT_DIR/bin/rg ]; then
        function apts() {
            # Filter results by those that actually contain the name
            apt-cache search $1 | rg $1
        }
    fi

else
    alias upd='sudo pacman -Sy'
    alias upg='sudo pacman -Syu'
fi

# Uncomment to use specific installed versions if available
# if [ -f /usr/bin/python3.10 ]; then
#     alias py='python3.10'
# fi

##############################################################################
#
# Applications
#
##############################################################################

export SUBLIME="$HOME/.config/sublime-text"
export SUBLIME_PKGS="$SUBLIME/Packages"
export SUBLIME_PREFS="$SUBLIME_PKGS/User"
export SUBLIME_SNIPS="$SUBLIME_PKGS/Sublime Text 3 Snippets"

##############################################################################
#
# Docker
#
##############################################################################

# Prune stopped containers from the container list
alias dprune='docker container prune -f'

# Remove dangling images (shown as SHAs in list)
# This also clears the build cache
alias docklean='docker rmi $(docker images --filter dangling=true -q --no-trunc)'
