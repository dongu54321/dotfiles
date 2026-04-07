#!/bin/bash
mkdir -p "$HOME"/podman/appdata/navidrome
podman run --replace -d --network momonet --label io.containers.autoupdate=registry \
    --name navidrome \
    -p 127.0.0.1:4533:4533 \
    -v "$HOME"/podman/appdata/navidrome:/data \
    -v "/media/WD_Black_1TB/Music/Torrents/1001 Albums You Must Hear Before You Die - Part 01 - 0001-0050 [gnodde]/":/music/music \
    -v /media/WD_Black_1TB/Download/Music/download/:/music/download \
    -v /media/WD_Black_1TB/Download/Music/ASIA/:/music/Asia \
    -e ND_LOGLEVEL=info \
    docker.io/deluan/navidrome:latest