#!/bin/bash
cd /home/dragon/momopod/appdata/servarr || exit
podman pull -q lscr.io/linuxserver/bazarr



#alias pod-gen-sys='podman generate systemd --new --container-prefix "" --new --name --no-header --restart-sec 10 --separator "" --files'

cp systemd/*.service $HOME/.config/systemd/user
systemctl --user daemon-reload
systemctl --user enable immich.service immich-redis.service immich-postgres14.service
systemctl --user start immich.service immich-redis.service immich-postgres14.service
