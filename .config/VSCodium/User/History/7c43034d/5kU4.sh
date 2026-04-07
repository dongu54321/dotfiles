#!/bin/bash
RED='\033[0;31m'   #'0;31' is Red's ANSI color code
cd /home/dragon/momopod/appdata/servarr || exit

echo pulling images pls be patient
podman pull -q lscr.io/linuxserver/jellyfin
podman pull -q lscr.io/linuxserver/radarr
podman pull -q lscr.io/linuxserver/sonarr
podman pull -q lscr.io/linuxserver/qbittorrent
podman pull -q lscr.io/linuxserver/bazarr
podman pull -q lscr.io/linuxserver/prowlarr
# podman pull -q docker.io/deluan/navidrome:latest

#alias pod-gen-sys='podman generate systemd --new --container-prefix "" --new --name --no-header --restart-sec 10 --separator "" --files'
if [ -d ~/momopod/appdata ] && [ -d /media/hdd/servarr ]; then
    cp systemd/*.service $HOME/.config/systemd/user
    systemctl --user daemon-reload
    systemctl --user enable --now jellyfin radarr sonarr bazarr prowlarr qbittorrent
else
    echo -e "$RED ERROR  no momopod appdata folder"
    echo ERROR  no media hdd servarr folder
    echo ERROR Please make sure HDD is mounted RIGHT and momopod folder is created
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
fi



#copy caddy files and reload caddy here
