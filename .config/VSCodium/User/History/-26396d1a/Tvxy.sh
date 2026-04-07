#!/bin/bash
curl -d "Backup Started Keep Your PC awake" ntfy.sh/momoin_vip
find /media/WD_Black_1TB/Backup/momo.nohost.me/ -type f -mtime +30 -delete
rsync -a --delete admin@momo.nohost.me:/home/yunohost.backup/archives/ /media/WD_Black_1TB/Backup/momo.nohost.me/

for file in /media/WD_Black_1TB/Backup/momo.nohost.me/*; do pgpgram backup --size 1000 $file; done
curl -d "Backup Done!" ntfy.sh/momoin_vip
#rsync -a --delete /media/WD_Black_1TB/Backup/momo.nohost.me/ admin@momo.nohost.me:/home/yunohost.backup/archives/