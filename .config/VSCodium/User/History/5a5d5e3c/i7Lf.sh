#!/bin/bash
cd /home/vugia || exit
curl ntfy.sh \
    -d '{
        "topic": "momoin_vip",
        "message": "cronjob start please keep your pc awake!",
        "title": "Home-vugia backup",
        "tags": ["warning","cd"],
        "priority": 4,
    }'

tar --exclude-backups \
    --exclude-from=/home/vugia/scripts/exclude_file.txt \
-I zstd -cpf /media/WD_Black_1TB/Backup/home-vugia-$(date '+%Y-%m-%d').tar.zst .

cd /media/WD_Black_1TB/Backup/ || exit
pgpgram backup --size 1000 ./*.zst && /bin/rm -f ./*.zst
/bin/rm -f /home/vugia/.cache/pgpgram/*
curl -H "Title: Home-Vugia Backup Finish!" -H "Priority: urgent" -H "Tags: warning" -d "momoin" ntfy.sh/momoin