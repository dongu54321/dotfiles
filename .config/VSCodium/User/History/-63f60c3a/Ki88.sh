#!/bin/bash
#####################################################################################
#                   install some usefull things
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt install -y curl gpg bsdmainutils python3-venv wget git micro
#####################################################################################
#                   Setup alvistack Repository and install podman
echo 'deb https://ftp.gwdg.de/pub/opensuse/repositories/home:/alvistack/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/home:alvistack.list
curl -fsSL https://download.opensuse.org/repositories/home:alvistack/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_alvistack.gpg > /dev/null

sudo tee -a /etc/apt/sources.list << EOF

deb http://deb.debian.org/debian/ unstable main non-free contrib
deb-src http://deb.debian.org/debian/ unstable main non-free contrib

EOF

sudo tee -a /etc/apt/preferences.d/99my-custom-repository << EOF
# Never prefer packages from the my-custom-repo repository
Package: *
Pin: origin ftp.gwdg.de
Pin-Priority: 1

# Allow upgrading only my-specific-software from my-custom-repo
Package: podman
Pin: origin ftp.gwdg.de
Pin-Priority: 550

Package: *
Pin: release a=unstable
Pin-Priority: 50

Package: chromium chromium-sandbox chromium-common
Pin: release a=unstable
Pin-Priority: 990


Package: firefox libnss3 libnss3:i386 libnss3-dev
Pin: release a=unstable
Pin-Priority: 990

EOF

sudo apt update
sudo apt install -y uidmap netavark aardvark-dns #fuse-overlayfs slirp4netns
sudo apt install podman firefox -y
#####################################################################################