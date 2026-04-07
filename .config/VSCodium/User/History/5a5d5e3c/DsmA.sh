#!/bin/bash
cd /home/vugia || exit
tar --exclude-backups \
    --exclude-from=/home/vugia/scripts/exclude_file.txt \
-I zstd -cpf /media/WD_Black_1TB/Backup/home-vugia-$(date '+%Y-%m-%d').tar.zst .