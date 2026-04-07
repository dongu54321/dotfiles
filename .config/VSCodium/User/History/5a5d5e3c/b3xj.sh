#!/bin/bash
cd /home/vugia || exit
tar -I zstd -cpf home-$(date '+%Y-%m-%d').tar.zst \
    --exclude=*.tar.gz \
    --exclude=*.tar.zst \
    --exclude=.cache \
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
    --exclude="VirtualBox VMs" \
--warning=no-file-changed vugia