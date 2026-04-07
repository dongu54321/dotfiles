#!/bin/bash
sudo apt install zsh git -y
#sudo pacman -S zsh git
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sed -i 's/.*ZSH_THEME=".*/ZSH_THEME="agnoster"/g' ~/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

sed -i 's/plugins=(git)/plugins=(z zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc
sed -i 's,# HIST_STAMPS,HIST_STAMPS,g' ~/.zshrc
tee -a ~/.zshrc << EOF
export HISTORY_IGNORE="(*6789*|exit)"
export PATH=$HOME/.local/bin/:$PATH
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi
EOF