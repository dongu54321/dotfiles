#!/bin/bash
#manual podman auto-update
cd /home/vugia/podman || exit
echo "Trilium:16600"
mkdir -p /home/vugia/podman/appdata/trilium
podman run --replace -d --label "io.containers.autoupdate=registry" \
    --name=trilium -p 16600:8080 \
    -e "USER_UID=1000" -e "USER_GID=1001" \
    -v ./appdata/trilium:/home/node/trilium-data \
    docker.io/zadam/trilium

echo "Homepage:16601"
mkdir -p /home/vugia/podman/appdata/homepage
podman run --replace -d --label "io.containers.autoupdate=registry" \
    --name homepage \
    -e PUID=1000 -e PGID=1001 -e TZ=Asia/bangkok \
    -v ./appdata/homepage:/app/config \
    -p 16601:3000 --network momo \
    ghcr.io/benphelps/homepage:latest
