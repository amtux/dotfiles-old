#!/bin/bash

##############################################
# usage:                                     #
#   cd dotfiles/                             #
#   chmod 755 setup-env.sh                   #
#   sudo su -c './setup-env.sh <username>'   #
#   username will be created if doesnt exist #
##############################################

set -eux

if [ $# -lt 1 ]; then
    echo "usage: $0 <username>"
    echo "username: name of user you want to set the env for"
    exit 1
else
    USER=$1
fi

# create user & add to sudoers 
if ! getent passwd $USER; then
    # create user if doesnt exist
    useradd -m -U $USER
else
    echo "user $USER already exists - skipping user creation"
fi

if ! su $USER -c "sudo -v"; then
    # add user to sudoers if not already in sudoers
    echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER
fi

# update packages
apt-get update && apt-get upgrade -y

# install zsh
apt-get install -y git wget curl zsh tmux
su $USER <<'EOF'
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || echo "maybe i didnt change shell"
sed -i '/ZSH_THEME/s/robbyrussell/af-magic/' file
EOF
chsh -s $(which zsh) $USER

# install golang
apt-get install -y bison
su $USER <<'EOF'
zsh < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source ~/.gvm/scripts/gvm
gvm install go1.4.3
gvm use go1.4.3 --default
go get golang.org/x/tools/cmd/godoc
EOF

# remove vim from something better ;)
apt-get remove -y vim || echo "vim not on system - so not removed"

# install neovim
apt-get install -y software-properties-common
add-apt-repository -y ppa:neovim-ppa/unstable
apt-get update
apt-get install -y python-dev python-pip python3-dev python3-pip
apt-get install -y neovim

#neovim config
#wget -O ~/.config/nvim/init.vim https://raw.githubusercontent.com/amtux/dotfiles/master/nvim/init.vim
su $USER <<'EOF'
mkdir -p ~/.config/nvim/{colors,autoload}
wget -O ~/.config/nvim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
wget -O ~/.config/nvim/colors/molokai.vim https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim
cp nvim/init.vim ~/.config/nvim/
EOF

# install utils
apt-get install -y nmon htop

#check if vim symlink gets set
ln -s $(which nvim) /usr/bin/vim || echo "couldn't symlink nvim to vim - maybe it's already set"
