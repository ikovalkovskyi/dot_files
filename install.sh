#!/bin/bash

mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/alacritty

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim 2>/dev/null

if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ -f /usr/local/bin/virtualenvwrapper.sh ] && [ ! -d $HOME/.virtualenvs/nvim ]; then
    mkvirtualenv nvim
    pip install neovim black
    deactivate
fi

opts="-s"
if [ "${1}" = "-f" ]; then
    opts="-sf"
fi

cd ~
ln ${opts} $HOME/dot_files/.bash_functions .bash_functions
ln ${opts} $HOME/dot_files/.bash_aliases .bash_aliases
ln ${opts} $HOME/dot_files/.env_vars .env_vars
ln ${opts} $HOME/dot_files/.zshrc .zshrc
ln ${opts} $HOME/dot_files/.gitconfig .gitconfig
ln ${opts} $HOME/dot_files/.p10k.zsh .p10k.zsh
ln ${opts} $HOME/dot_files/.tmux.conf .tmux.conf
ln ${opts} $HOME/dot_files/.tmux.conf.local .tmux.conf.local
ln ${opts} $HOME/dot_files/.vimrc .vimrc
ln ${opts} $HOME/dot_files/alacritty.yml ${XDG_CONFIG_HOME:-$HOME/.config}/alacritty/alacritty.yml

# Download Fonts
# MacOS:
# https://github.com/tonsky/FiraCode
# Linux:
# https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf

# Alacrity

#font:
#  normal:
#    family: "MesloLGS NF"


# Workspace:
# for repo in $(ls ~/lohika/blameless/workspace/blameless); do cp prepare-commit-msg ~/lohika/blameless/workspace/blameless/$repo/.git/hooks/ ; done
