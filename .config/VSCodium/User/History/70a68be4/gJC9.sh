#!/bin/bash
cd /home/dragon/momopod/appdata/adguard || exit

echo pulling images pls be patient
podman pull docker.io/library/caddy

cp ./*.service $HOME/.config/systemd/user
systemctl --user daemon-reload
systemctl --user enable --now caddy