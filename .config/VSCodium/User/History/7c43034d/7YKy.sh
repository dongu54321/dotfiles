#!/bin/bash
cd /home/dragon/momopod/appdata/servarr || exit

echo pulling images
podman pull -q lscr.io/linuxserver/jellyfin
podman pull -q lscr.io/linuxserver/radarr
podman pull -q lscr.io/linuxserver/sonarr
podman pull -q lscr.io/linuxserver/qbittorrent
podman pull -q lscr.io/linuxserver/bazarr
podman pull -q lscr.io/linuxserver/prowlarr
# podman pull -q docker.io/deluan/navidrome:latest

#alias pod-gen-sys='podman generate systemd --new --container-prefix "" --new --name --no-header --restart-sec 10 --separator "" --files'

cp systemd/*.service $HOME/.config/systemd/user
systemctl --user daemon-reload
systemctl --user enable --now jellyfin radarr sonarr bazarr prowlarr qbittorrent

#copy caddy files and reload caddy here
