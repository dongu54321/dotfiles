#!/bin/bash
cd /home/vugia || exit
tar --exclude='*.tar.gz' \
    --exclude='*.tar.zst' \
    --exclude=.cache \
    --exclude=Cache \
    --exclude=.cargo \
    --exclude=.dbus \
    --exclude=.gvfs \
    --exclude=.local/share/gvfs-metadata \
    --exclude=.local/share/Trash \
    --exclude=.recently-used \
    --exclude=.thumbnails \
    --exclude=.xsession-errors \
    --exclude=.Trash \
    --exclude=.steam \
    --exclude=Downloads \
    --exclude=GitHub \
    --exclude=Public \
    --exclude=Steam \
    --exclude=Templates \
    --exclude=VirtMachine \
    --exclude-backups \
    -I zstd -cpf home-$(date '+%Y-%m-%d').tar.zst \
vugia