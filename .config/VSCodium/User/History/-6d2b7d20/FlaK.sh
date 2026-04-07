#!/usr/bin/env bash
podman auto-update

#nextcloud
cd /momopod/appdata/nextcloud
podman-compose pull && podman-compose down && podman-compose up -d

#wallabag wallabag|wallabag
cd /momopod/appdata/wallabag
podman-compose pull && podman-compose down && podman-compose up -d

#invidious
cd /momopod/appdata/invidious
podman-compose pull && podman-compose down && podman-compose up -d

#vaulwarden
cd /momopod/appdata/vaulwarden
podman-compose pull && podman-compose down && podman-compose up -d

#servarr
cd /media/HDD500/servarr/
podman-compose pull && podman-compose down && podman-compose up -d