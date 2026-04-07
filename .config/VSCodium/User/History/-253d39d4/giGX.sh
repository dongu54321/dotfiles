#!/bin/bash
RED='\033[0;31m'   #'0;31' is Red's ANSI color code
GREEN='\033[0;32m'   #'0;32' is Green's ANSI color code
YELLOW='\033[0;33m'   #'1;32' is Yellow's ANSI color cod

#####################################################################################
#                   install some usefull things
echo -e "$GREEN ################################################"
echo -e "$YELLOW Update and install some usefull things"
sudo sed -i 's,deb cdrom,#deb cdrom,g' /etc/apt/sources.list
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt install -y curl gpg python3-venv wget git micro jq
# sudo apt install -y vlc
# curl -fsSL https://tailscale.com/install.sh | sudo sh
echo -e "$GREEN ################################################"
echo -e "$YELLOW INSTALL Tailscale"
# wget https://tailscale.com/install.sh
# chmod +x install.sh && ./install.sh
# rm ./install.sh
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt-get update && sudo apt-get install tailscale
echo sudo tailscale up
#####################################################################################
#                   nebula install
echo -e "$GREEN ################################################"
echo -e "$YELLOW INSTALL Nebula"
# LATEST_RELEASE_URL=https://github.com/slackhq/nebula/releases/latest
# release_url=$(curl -Ls --retry 5 --retry-delay 5 -o /dev/null -w %{url_effective} $LATEST_RELEASE_URL)
# version=${release_url##*/}
# download_url=https://github.com/slackhq/nebula/releases/download/$version/nebula-linux-amd64.tar.gz
# download_file=./nebula.tar.gz
# wget -q --show-progress "$download_url" -O $download_file
# tar -xzf nebula.tar.gz
# rm nebula.tar.gz
# sudo mv nebula /usr/local/bin/
# sudo mv nebula-cert /usr/local/bin/
sudo apt install -y nebula
#Install nebula
cd "/home/dragon/$HOSTNAME" || exit
sudo mkdir -p /etc/nebula
sudo mv ./nebula.service /etc/systemd/system/
sudo mv ./* /etc/nebula/
sudo chown -R root:root /etc/nebula
sudo systemctl daemon-reload
sudo systemctl enable --now nebula
#####################################################################################
#                   config system
echo -e "$GREEN ################################################"
echo -e "$YELLOW CONFIG SYSTEM"
# sudo sed -i 's,#PasswordAuthentication yes,PasswordAuthentication no,g' /etc/ssh/sshd_config #Disable password Auth
sudo sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
sudo sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sudo sed -i -e "/Port /c\Port 2216" /etc/ssh/sshd_config #Change ssh port to 2216
sudo tee -a /etc/ssh/sshd_config << EOF
Match Address 172.16.0.0/24
    PasswordAuthentication yes
    PermitRootLogin yes
Match all
EOF
#Change podman unprivileged ports
sudo tee -a /etc/sysctl.conf << EOF
net.ipv4.ip_unprivileged_port_start=53
EOF
sudo sysctl -p
sudo loginctl enable-linger "$USER"

# Set up update repos
sudo mkdir -p /opt/.update
cd /opt/.update || exit
sudo git clone https://momo.nohost.me/gitea/vugia/update

#####################################################################################

#                   Setup alvistack Repository and install podman
echo -e "$GREEN ################################################"
echo -e "$YELLOW INSTALL podman"
echo 'deb https://ftp.gwdg.de/pub/opensuse/repositories/home:/alvistack/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/home:alvistack.list
curl -fsSL https://download.opensuse.org/repositories/home:alvistack/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_alvistack.gpg > /dev/null

sudo tee -a /etc/apt/preferences.d/99my-custom-repository << EOF
# Never prefer packages from the my-custom-repo repository
Package: *
Pin: origin ftp.gwdg.de
Pin-Priority: 1

# Allow upgrading only my-specific-software from my-custom-repo
Package: podman
Pin: origin ftp.gwdg.de
Pin-Priority: 550

EOF

sudo apt update
sudo apt install -y uidmap netavark aardvark-dns slirp4netns #fuse-overlayfs slirp4netns
sudo apt install podman -y
sudo systemctl disable --now podman-auto-update.service podman-auto-update.timer podman-clean-transient.service \
    podman-restart.service podman.socket podman.service
podman info >/dev/null
systemctl --user enable podman-auto-update.timer
podman network create --ignore --subnet 192.16.0.1/16 momonet
sudo apt install -y cockpit cockpit-podman soundconverter

#####################################################################################
#                   podman
mkdir -p $HOME/momopod/{appdata,logs,scripts}
mkdir -p $HOME/.config/systemd/user/

#####################################################################################
#                   bashrc alias
echo -e "$GREEN ################################################"
echo -e "$YELLOW  zsh and alias"
sudo apt install zsh tmux -y
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

sed -i 's/.*ZSH_THEME=".*/ZSH_THEME="agnoster"/g' ~/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i 's/plugins=(git)/plugins=(z zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc
sed -i 's,# HIST_STAMPS,HIST_STAMPS,g' ~/.zshrc
#Enable tmux mouse
echo "set -g prefix C-a
# Remove the old prefix
unbind C-b
# Send Ctrl+a to applications by pressing it twice
bind C-a send-prefix
setw -g mouse on
" >> ~/.tmux.conf

tee -a $HOME/.zshrc << EOF
alias caddyreload='podman exec caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile'
alias _sysuser='systemctl --user'
alias _daemon='systemctl --user daemon-reload'
alias _restart='systemctl --user restart'
alias _history='history -c && echo clear > ~/.bash_history'
alias wav2flac='soundconverter -b ./*.wav -f flac -o ./ && rm *.wav'
alias _space='sudo du -h -d 1 . | grep G'
alias _space2='sudo du | sort -nr | head -30'
alias tmuxx='tmux new-session \; split-window -h \; split-window -v \; attach'
podmansystemd() {
	#cd ~/.config/systemd/user/ || exit
	podman generate systemd --name --new "$1" > ~/.config/systemd/user/container-"$1".service
	systemctl --user daemon-reload
	podman rm -f $1
	systemctl --user enable --now container-"$1".service
	#cd - || exit
}

export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
alias docker='podman'
alias _compose='podman-compose --dry-run up'
alias _compose-pod='podman-compose --dry-run --in-pod up'
alias pod-com-up='podman-compose down; podman-compose up -d'
alias _compose-up='podman-compose down; podman-compose up -d'
alias polog='podman logs -f --tail 20'
alias popsname="podman ps --format '{{.Names}}'"
alias popsport="podman ps --format '{{.Names}} :  {{.Ports}}"
alias podmanps='podman ps --format "{{.Names}}   :  {{.Status}}  : {{.State}} : {{.RunningFor}} {{.Command}}"'


EOF
##
lsblk -f
echo '#UUID= /media/hdd auto nofail 0 0' | sudo tee -a /etc/fstab
echo "Remember to mount HDD to /media/hdd in fstab"

sudo mkdir -p /media/hdd
echo '*************************************************************
##               IMPORTANT
sudo micro /etc/fstab
sudo chown -R dragon:dragon /media/hdd
mkdir -p /media/hdd/servarr/{torrents,user,media}
mkdir -p /media/hdd/servarr/torrents/{tv,anime,books,movies,music,custom}
mkdir -p /media/hdd/servarr/media/{tv,anime,books,movies,music,custom}
mkdir -p /media/hdd/servarr/user/{downloads,artist}
mkdir -p "/media/hdd/servarr/user/artist/Various Artists"
'
rm -rf "/home/dragon/$HOSTNAME"
sudo systemctl restart ssh && sudo chsh -s $(which zsh)
