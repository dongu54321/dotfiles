#!/usr/bin/env bash
sudo apt update && sudo apt upgrade -y
LATEST_RELEASE_URL=https://github.com/rustdesk/rustdesk/releases/latest
# Find latest version tag
release_url=$(curl -Ls -o /dev/null -w %{url_effective} $LATEST_RELEASE_URL)
version=${release_url##*/}
# Determine download URL and install path
download_url=https://github.com/rustdesk/rustdesk/releases/download/$version/rustdesk-$version-x86_64.deb
download_file=./rustdesk.deb
#wget -q --show-progress $download_url -O $download_file
wget -q --show-progress $download_url -O $download_file
# install rustdesk
sudo apt -f install ./rustdesk.deb -y
#sudo apt-get -f install -y
rm ./rustdesk.deb
# set password
sleep 5
sudo rustdesk --password DragonaKnight6789\!\@\#
# get rustdesk id
sudo rustdesk --get-id
    #history -c && echo '' > ~/.bash_history