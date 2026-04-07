#!/bin/bash
cd /home/vugia || exit
tar --exclude-backups \
    --exclude-from=exclude_file.txt \
-I zstd -cpf home-vugia-$(date '+%Y-%m-%d').tar.zst .