#!/bin/bash

#       momo.nohost.me backup sync
#curl -d "rsync cron run" ntfy.sh/momoin-test-log
cd /media/WD_Black_1TB/Backup/momo.nohost.me/ || exit
mkdir -p .rsync-partial
rsync -a --timeout=7100 --partial-dir=.rsync-partial admin@momo.nohost.me:/home/yunohost.backup/archives/ /media/WD_Black_1TB/Backup/momo.nohost.me/
find /media/WD_Black_1TB/Backup/momo.nohost.me/ -type f -mtime +20 -delete
#rsync -a --delete admin@momo.nohost.me:/home/yunohost.backup/archives/ /media/WD_Black_1TB/Backup/momo.nohost.me/
for file in /media/WD_Black_1TB/Backup/momo.nohost.me/*; do pgpgram backup --size 1000 "$(basename "$file")"; done

cd /home/ || exit

#tar -I zstd -cvpf --exclude-caches /tmp/home-$(date '+%Y-%m-%d').tar.zst /home/vugia

rm -rf /home/vugia/.cache/pgpgram/*