#!/bin/bash

#       momo.nohost.me backup sync
#curl -d "rsync cron run" ntfy.sh/momoin-test-log
cd /media/WD_Black_1TB/Backup/momo.nohost.me/ || exit
rsync -a --delete --timeout=7200 --partial-dir=.rsync-partial admin@momo.nohost.me:/home/yunohost.backup/archives/ /media/WD_Black_1TB/Backup/momo.nohost.me/
find /media/WD_Black_1TB/Backup/momo.nohost.me/ -type f -mtime +30 -delete
#rsync -a --delete admin@momo.nohost.me:/home/yunohost.backup/archives/ /media/WD_Black_1TB/Backup/momo.nohost.me/
for file in /media/WD_Black_1TB/Backup/momo.nohost.me/*; do pgpgram backup --size 1000 "$file"; done