#!/bin/bash

##############################################
# usage:                                     #
#   cd dotfiles/                             #
#   make changes to config.sh                #
#   sudo -s                                  #
#   ./setup-env.sh config.sh    #
##############################################

set -ex

# function taken from https://get.docker.com/ script
command_exists() {
	command -v "$@" > /dev/null 2>&1
}

# source config file
if [ $# -lt 1 ]; then
    echo "usage: $0 /path/to/config.sh"
    echo "pass the config.sh with correct params"
    exit 1
else
    CONF_FILE=$1
    if ! [ -f $CONF_FILE ]; then
        echo "ERROR: config file: $CONF_FILE not found"
        exit 1
    else
        echo "found config: $CONF_FILE"
        source $CONF_FILE
    fi
fi

# confirm required var target_user is provided via config file
if [ -z "$target_user" ]; then
    echo "ERROR: variable target_user user not passed from config (required)"
    exit 1
fi

# create user if doesnt exist
if ! getent passwd $target_user; then
    # create user if doesnt exist
    useradd -m -U $target_user
else
    echo "user $target_user already exists - skipping user creation"
fi

# give user sudo
if ! command_exists sudo; then
    apt-get install -y sudo
fi
if ! su $target_user -c "sudo -v"; then
    # add user to sudoers if not already in sudoers
    echo "$target_user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$target_user
fi

# update packages
if [ "$upgrade_packages" == "true" ]; then
    echo "upgrading packages"
    apt-get update && apt-get upgrade -y
fi

# install zsh
if [ "$install_ohmyzsh" == "true" ]; then
    echo "installing oh_my_zsh"
    apt-get install -y zsh git
    su $target_user << 'EOF'
    cd ~/
    git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    [ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.orig
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
EOF
    chsh -s $(which zsh) $target_user
fi

if [ "$install_neovim" == "true" ]; then
    # install neovim
    apt-get install -y software-properties-common
    add-apt-repository -y ppa:neovim-ppa/unstable
    apt-get update
    apt-get install -y python-dev python-pip python3-dev python3-pip
    apt-get install -y neovim
    pip3 install neovim
    if [ "$install_neovim_config" == "true" ]; then
        #neovim config
        su $target_user <<'EOF'
        mkdir -p ~/.config/nvim/{colors,autoload}
        wget -O ~/.config/nvim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        wget -O ~/.config/nvim/colors/molokai.vim https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim
        cp nvim/init.vim ~/.config/nvim/
EOF
    fi
    if [ "$alias_neovim_to_vim" == "true" ]; then
        echo 'alias vim="nvim"' >> /home/$target_user/.zshrc
    fi
fi

# install utils
if [ "$install_utils" == true ]; then
    apt-get install -y nmon htop git wget curl zsh tmux
fi

# install docker
if [ "$install_docker" == "true" ]; then
    wget -qO- https://get.docker.com/ | sh
    sudo usermod -aG docker $target_user
    apt-get -y install python-pip
    pip install docker-compose
fi