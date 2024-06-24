
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


##############################################################################
#
# Configurations
#
##############################################################################

# Core (backend) configurations
zshrc_core=".zshrc.core.zsh"
if [ -f $HOME/$zshrc_core ]; then
    export RC_CORE="$HOME/$zshrc_core"
    source $RC_CORE
fi

# User configurations (traditional .zshrc content)
zshrc_user=".zshrc.user.zsh"
if [ -f $HOME/$zshrc_user ]; then
    export RC_USER="$HOME/$zshrc_user"
    source $RC_USER
fi

# Arch-specific configurations
zshrc_arch=".zshrc.linux.zsh"
if [ -f $HOME/$zshrc_arch ]; then
    export RC_ARCH="$HOME/$zshrc_arch"
    source $RC_ARCH
fi

# Embedded configurations
zshrc_emb=".zshrc.embedded.zsh"
if [ -f $HOME/.zshrc.embedded.zsh ]; then
    export RC_EMBEDDED="$HOME/$zshrc_emb"
    source $RC_EMBEDDED
fi

# Private system configurations, such as those tracked in an external private
# repository.
zshrc_private=".zshrc.private.zsh"
if [ -f $HOME/$zshrc_private ]; then
    export RC_PRI="$HOME/$zshrc_private"
    source $RC_PRI
fi

# Local system configurations
# This should always go last so that it can override anything
zshrc_local=".zshrc.local.zsh"
if [ -f $HOME/$zshrc_local ]; then
    export RC_LOCAL="$HOME/$zshrc_local"
    source $RC_LOCAL
fi


##############################################################################
#
# Plugin Activations
#
##############################################################################

# # This is the line copied in from fzf install script
# # Install script will see this line and ignore the auto-append
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh

# # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
