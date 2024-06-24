#!/bin/bash

bin_dir="$HOME/bin"
repos_dir="$HOME/Repos"
gits_dir="$HOME/Gits"
configs_dir="$repos_dir/my-configs"

# Quick function for initializing directories that should exist upon first
# configuration pass.
dirinit()
{
	if [ -z $1 ]; then
		return
    	fi

    	if [ ! -d $1 ]; then
        	mkdir -p $1
    	fi
}

printhelp()
{
	echo "Basic helper script for quickly installing the best development"
	echo "environment ever on Debian/Ubuntu."

	echo "Options:"
	echo "  --core	Core repos, directories, packages, and files."
	echo "  --rust	Rust language and core packages."
	echo "  --zsh	ZSH repos and files."
	echo "  --help	Show this."
}

core()
{
    	backup_ext="factory-default"

	for file in profile bashrc; do
		backup_file=.$file.$backup_ext
		if [ ! -f $HOME/$backup_file ]; then
        		echo "Backing up .$file as $backup_file"
			cp -i $HOME/.$file $HOME/$backup_file
        	fi
    	done

	dirinit $bin_dir
	dirinit $gits_dir
	dirinit $repos_dir

	echo "-----> Installing core packages..."
	sudo apt install --no-install-recommends \
build-essential \
software-properties-common \
curl \
zsh \
vim-nox\
python3-dev \
python3-pip \
python3-virtualenv \
python3-serial \
python3-tomli \
make \
cmake \
cmake-doc \
ninja-build \
keychain \
speedcrunch \
terminator \
wget \
xclip \
xsel

	echo "-----> Update pip"
	python3 -m pip install --user -U pip

	hidden_files=(
		alacritty.toml
		gdbinit
		gitconfig
		ripgreprc
	)

	for file in ${hidden_files[@]}; do
		if [ ! -f $HOME/.$file ]; then
			ln -sv $configs_dir/$file $HOME/.$file
		fi
	done

	if [ ! -d $gits_dir/git-number ]; then
		git clone --depth 1 https://github.com/holygeek/git-number.git $gits_dir/git-number
		ln -sv $PWD/git-number/git-* $bin_dir
	fi

	if [ ! -d $HOME/.fzf ]; then
		echo "-----> Installing FZF (in the reliable manual way)"
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
		~/.fzf/install
	fi

	if [ ! -d $HOME/.vim/plugged ]; then
		echo "-----> Setting up vim-plugged"
		mkdir -p $HOME/.vim/plugged
		curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		ln -sfv $configs_dir/vimrc ~/.vimrc
	fi
}

rust()
{
	installer=$HOME/Downloads/rust.sh

	if [ ! -f $installer ]; then
		# Send it to a file first so we avoid the BAD habit of immediately
		# executing a script from the internet before inspecting it (why Rust
		# has this as the recommended execution is wild)
		echo "-----> Retreiving rust installer"
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > $installer
		less $installer

		echo "Execute rust installer '${installer}'? [y/N]"
        	# Wait for input for 30s before using the default option.
        	read -t 30 replace

		if [[ $replace =~ "y" ]] || [[ $replace =~ "Y" ]]; then
			bash $installer
		else
			return || exit 1
		fi

		export PATH=$HOME/.cargo/bin:$PATH
		echo "Export ~/.cargo/bin is in the PATH, or relog for profile to pick it up."
	fi

	if [ ! -f $HOME/.cargo/bin/bat ]; then
		echo "-----> Installing core rust packages"
		cargo install ripgrep fd-find exa bat
	fi

	if [ ! -d $gits_dir/nerd-fonts ]; then
		echo "-----> Installing Hack and Meslo nerdfonts"
		git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git $gits_dir/nerd-fonts
		cd nerd-fonts
		./install.sh Hack Meslo

		echo "-----> Installing lsd"
		cargo install lsd
	fi

	if [ ! -f $HOME/.cargo/bin/alacritty ]; then
		# Currently have to manually track its dependencies
		echo "-----> Installing alacritty dependencies"
		sudo apt install --no-install-recommends \
pkg-config \
libfreetype6-dev \
libfontconfig1-dev \
libxcb-xfixes0-dev \
libxkbcommon-dev

		echo "-----> Installing alacritty"
		cargo install alacritty
	fi
}

# Do not invoke directly; go through zshrc()
setup_zsh()
{
	if [ ! -d $HOME/.zprompts ]; then
		echo "-----> Setting up ~/.zprompts"
		mkdir -p $HOME/.zprompts
	fi

	if [ ! -f ~/.zshrc.core.zsh ]; then
		echo "-----> Forwarding zsh profile to bash profile"
		cp -v $configs_dir/zprofile $HOME/.zprofile

		zshrc_files=(
			zshrc.core.zsh
			zshrc.user.zsh
			zshrc.linux.zsh
			zshrc.embedded.zsh
		)

		echo "-----> Linking/copying zshrc files"
		for file in ${zshrc_files[@]}; do
			ln -svf $configs_dir/$file $HOME/.$file
		done

		cp -v $configs_dir/zshrc.local.zsh $HOME/.zshrc.local.zsh

		ln -svf $configs_dir/zshrc.zsh $HOME/.zshrc
	fi

	if [ ! -d $gits_dir/zsh-autocomplete ]; then
		echo "-----> Setting up zsh-autocomplete"
		git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git $gits_dir/zsh-autocomplete

		rc_file=zshrc.autocomplete.zsh
		ln -svf $configs_dir/$rc_file $HOME/.$rc_file
	fi

	if [ ! -d $gits_dir/powerlevel10k ]; then
		echo "-----> Setting up Powerlevel10k"
		git clone --depth 1 https://github.com/romkatv/powerlevel10k.git $gits_dir/powerlevel10k

		prompt=prompt_powerlevel10k_setup
		ln -sv $gits_dir/powerlevel10k/$prompt $HOME/.zprompts/$prompt
	fi

	echo "Now set up zsh as the default terminal:"
	echo "On own machine: sudo chsh -s $(which zsh)"
	echo "System-restricted chsh: touch ~/.zsh_from_bash"
}

zshrc()
{
	if [ -f $HOME/.zshrc ]; then
		less $HOME/.zshrc
		echo ".zshrc exists; proceed? [y/N]"
        	# Wait for input for 30s before using the default option.
        	read -t 30 replace

		if [[ $replace =~ "y" ]] || [[ $replace =~ "Y" ]]; then
			setup_zsh || exit 1
		else
			return || exit 1
		fi
	else
		setup_zsh || exit 1

	fi
}

if [ -z $1 ]; then
	printhelp
else

for arg in "$@"
do
	case "$arg" in
    	--core*)
		core
		;;
	--rust*)
		rust
		;;
	--zsh*)
		zshrc
		;;
    	*)
    		printhelp
		;;
    	esac
done
fi
