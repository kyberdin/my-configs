# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

#Include toolchains in path
ptools="$HOME/Toolchains"
if [ -d $ptools ]; then
    if [ -d "$ptools/gnuarmemb/latest" ]; then
        PATH="$ptools/gnuarmemb/latest/bin:$PATH"
    fi

    if [ -d "$ptools/jlink/latest" ]; then
        # jlink has DLLs that should be made available
        LD_LIBRARY_PATH="$ptools/jlink/latest:$LD_LIBRARY_PATH"

        # symlink the desired tools in ~/bin to avoid other bin deliverables
    fi

    if [ -d "$ptools/cmake/latest" ]; then
        PATH="$ptools/cmake/latest/bin:$PATH"
    fi

    if [ -d "$ptools/nordic/nrf-command-line-tools/latest" ]; then
        # nrfjprog has DLLs that should be made available
        LD_LIBRARY_PATH="$ptools/nordic/nrf-command-line-tools/latest/lib:$LD_LIBRARY_PATH"

        # symlink the desired tools to avoid other bin deliverables
    fi

    if [ -d "$ptools/ftdi/latest/build" ]; then
        # FTDI DLLs should be made available
        LD_LIBRARY_PATH="$ptools/ftdi/latest/build:$LD_LIBRARY_PATH"
    fi

    # Add Zephyr ARM bins to path
    if [ -d "$ptools/zephyr-sdk/latest-arm" ]; then
        PATH="$ptools/zephyr-sdk/latest-arm/arm-zephyr-eabi/bin:$PATH"
    fi
fi
unset ptools

# Include Rust binaries
if [ -d "$HOME/.cargo" ]; then
    PATH="$HOME/.cargo/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# User-defined bins take precedence over all
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

if [ -z $XDG_CONFIG_HOME ]; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi

export PATH="$PATH"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
