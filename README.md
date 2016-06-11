#dotfiles

Whenever I get my hands on a VM, whether it's a VPS, Openstack nodes, or a Vagrant VMs, etc I always need to first spend time setting up the environment with a oh_my_zsh customized shell, a pre-configured neovim editor, and a set of tools required to do everyday work.

##Setup
```bash
sudo -s
cd dotfiles/
# make appropriate changes to config.sh file: change username, set unwanted actions to "false"
./setup-env.sh config.sh
```

##neovim rc file
Takes the useful stuff from [amix's ultimate vimrc](https://github.com/amix/vimrc) and adds useful plugins using [vim-plug](https://github.com/junegunn/vim-plug).
