#!/bin/bash
cd /home/vugia || exit
tar --exclude='*.tar.gz' \
    --exclude='*.tar.zst' \
    --exclude-backups \
    --exclude-from=exclude_file.txt \
    -I zstd -cpf home-$(date '+%Y-%m-%d').tar.zst \
vugia