#!/bin/bash
#sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y && sudo apt-get autoclean -y && sudo apt-get clean -y
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt install -y curl gpg bsdmainutils python3-venv wget git micro 
#*******************************************************************
#   Setup alvistack Repository and install podman

curl -fsSL https://download.opensuse.org/repositories/home:alvistack/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_alvistack.gpg > /dev/null

echo 'deb https://ftp.gwdg.de/pub/opensuse/repositories/home:/alvistack/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/home:alvistack.list
sudo tee -a /etc/apt/sources.list << EOF

deb http://deb.debian.org/debian/ testing main non-free contrib
deb-src http://deb.debian.org/debian/ testing main non-free contrib
EOF

sudo tee -a /etc/apt/preferences.d/99my-custom-repository << EOF
# Never prefer packages from the my-custom-repo repository
Package: *
Pin: origin ftp.gwdg.de
Pin-Priority: 1

# Allow upgrading only my-specific-software from my-custom-repo
Package: podman catatonit conmon containernetworking containernetworking-plugins containers-common cri-o-runc podman-netavark podman-aardvark-dns
Pin: origin ftp.gwdg.de
Pin-Priority: 550

Package: *
Pin: release a=testing
Pin-Priority: 50

Package: chromium chromium-sandbox chromium-common
Pin: release a=testing
Pin-Priority: 990


Package: firefox libnss3 libnss3:i386 libnss3-dev
Pin: release a=testing
Pin-Priority: 990

EOF

#sudo apt install -y uidmap netavark aardvark-dns #fuse-overlayfs slirp4netns
# sudo apt install -y podman-netavark podman-aardvark-dns python3-podman-compose podman
# sudo apt install podman firefox -y
.source  /etc/os-release
wget http://downloadcontent.opensuse.org/repositories/home:/alvistack/Debian_$VERSION_ID/Release.key -O alvistack_key
cat alvistack_key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/alvistack.gpg  >/dev/null

echo "deb http://downloadcontent.opensuse.org/repositories/home:/alvistack/Debian_$VERSION_ID/ /" | sudo tee /etc/apt/sources.list.d/alvistack.list

sudo tee -a /etc/apt/preferences.d/99my-custom-repository << EOF
# Never prefer packages from the my-custom-repo repository
Package: *
Pin: origin downloadcontent.opensuse.org
Pin-Priority: 1

# Allow upgrading only my-specific-software from my-custom-repo
Package: podman catatonit conmon containernetworking containernetworking-plugins containers-common cri-o-runc podman-netavark podman-aardvark-dns
Pin: origin downloadcontent.opensuse.org
Pin-Priority: 550
EOF

sudo apt update
sudo apt install catatonit conmon containernetworking containernetworking-plugins containers-common cri-o-runc

sudo apt --simulate install podman python3-podman-compose
sudo apt install podman python3-podman-compose

#*******************************************************************
#Change podman unprivileged ports
#echo 'net.ipv4.ip_unprivileged_port_start=53' | sudo tee -a /etc/sysctl.conf
#echo 'net.ipv4.ping_group_range=0 $MAX_UID' | sudo tee -a /etc/sysctl.conf
#sudo nano /etc/containers/registries.conf
