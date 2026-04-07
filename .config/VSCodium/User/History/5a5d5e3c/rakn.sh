#!/bin/bash
until ping -c1 1.1.1.1; do sleep 2; done;
cd /home/vugia || exit
curl ntfy.sh \
    -d '{
        "topic": "momoin_vip",
        "message": "cronjob start please keep your pc awake!",
        "title": "Home-vugia backup",
        "tags": ["warning"],
        "priority": 4
    }'

tar -I zstd -cpf /media/WD_Black_1TB/Backup/home-vugia-$(date '+%Y-%m-%d').tar.zst \
    --exclude-backups \
    --exclude-from=/home/vugia/scripts/exclude_file.txt .

cd /media/WD_Black_1TB/Backup/ || exit
pgpgram backup --size 1000 ./*.zst && /bin/rm -f ./*.zst
/bin/rm -f /home/vugia/.cache/pgpgram/*
curl -H "Title: Home-Vugia Backup Finished\!" -H "Priority: urgent" -H "Tags: warning" -d "Finished" ntfy.sh/momoin