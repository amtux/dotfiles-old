#dotfiles

This project allows me to setup a vanilla(ex. vagrant) environment with my own user, install needed packages(ex. tmux, zsh, neovim, golang) and add/edit configs for them

##Setup
```bash
cd dotfiles/
chmod 755 setup-env.sh
sudo su -c './setup-env.sh <username>'
```
`<username>` is the name of user you want to setup this environment for. A new one will be created and provided sudo access if it doesn't exist.

##neovim rc file
Takes the useful stuff from [amix's ultimate vimrc](https://github.com/amix/vimrc) and adds useful plugins using [vim-plug](https://github.com/junegunn/vim-plug).
