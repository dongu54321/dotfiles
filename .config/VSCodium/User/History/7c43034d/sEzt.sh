#!/bin/bash
cd /home/dragon/momopod/appdata/servarr || exit

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
systemctl --user enable immich.service immich-redis.service immich-postgres14.service
systemctl --user start immich.service immich-redis.service immich-postgres14.service
