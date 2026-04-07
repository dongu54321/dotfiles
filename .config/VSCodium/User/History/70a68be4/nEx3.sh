#!/bin/bash
cd /home/dragon/momopod/appdata/adguard || exit

podman pull docker.io/adguard/adguardhome

cp ./*.service $HOME/.config/systemd/user
systemctl --user daemon-reload
systemctl --user enable --now adguard