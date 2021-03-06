#!/bin/bash

# Import distro info variables
for f in /etc/*-release;
do
    . "$f"
done

PUT_IN_BASHRC=". ~/dotfiles/.bashrc"
if ! grep -q "$PUT_IN_BASHRC" ~/.bashrc;
then
    echo -e "\n$PUT_IN_BASHRC\n" >> ~/.bashrc
fi

# Packages to install
PACKAGES=(
vim
curl
tmux
automake
build-essential
terminator
)

# Prompt to install packages
read -p "Install packages? [N|y] " -n 1 -r
echo

if [[ "$REPLY" =~ ^[Yy]$ ]] # if yes
then

    if [ "$ID_LIKE" == "debian" ];
    then
        sudo apt-get update
        sudo apt-get install ${PACKAGES[@]}
    elif [ "$ID" == "arch" ];
    then
        sudo pacman -Su ${PACKAGES[@]}
    fi

    # I ♥ unity
    if [ "$XDG_CURRENT_DESKTOP" == "Unity" ];
    then
        sudo apt-get install \
            indicator-multiload \
            compizconfig-settings-manager \
            compiz-plugins-extra

        # TODO: find a way to import unity profile from command line
        echo "Remember to import your unity profile!";
    fi
fi

if [ ! -e ~/.vim/bundle ];
then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

# Create symlinks
ln -sf ~/dotfiles/.vimrc ~
ln -sf ~/dotfiles/.tmux.conf ~
ln -sf ~/dotfiles/.inputrc ~
ln -sf ~/dotfiles/.psqlrc ~
ln -sf ~/dotfiles/.git{config,ignore_global} ~
ln -sf ~/dotfiles/.vimrc ~/.vim/init.vim

# Create folders for nvim
mkdir -p \
    ~/.config \
    ~/.local/share/nvim/backup \
    ~/.config/terminator

ln -sf ~/.vim ~/.config/nvim
ln -sf ~/dotfiles/terminator.config ~/.config/terminator/config

# Install vim plugins
vim +PluginInstall +qall

NPM_PACKAGES=(
eslint
prettier
)

# if npm is installed
NPM=$(command -v npm)
if [ -x $NPM ];
then
    if ! grep -q "^prefix" ~/.npmrc;
    then
        echo "prefix=/home/martin/.local" >> ~/.npmrc
    fi

    echo "Installing ${NPM_PACKAGES[@]}"

    $NPM install -g ${NPM_PACKAGES[@]}
fi

# Prompt to install ctags
read -p "Do you want ctags (universal ctags)? [N|y] " -n 1 -r
echo

if [[ "$REPLY" =~ ^[Yy]$ ]] # if yes
then

    pushd ~/dotfiles

    git clone https://github.com/universal-ctags/ctags.git ctags
    cd ctags

    ./autogen.sh
    ./configure --prefix=$HOME/.local
    make -j2
    make install

    popd

    mkdir ~/.ctags.d
    ln -sf ~/dotfiles/.ctags ~/.ctags/AAA.ctags
fi

source ~/.bashrc
