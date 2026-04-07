#!/bin/bash
# run by cronjob in /etc/crontab
#45 8 * * 1 vugia /home/vugia/scripts/pgpgram_home_backup.sh > /dev/null 2>&1
until ping -c1 1.1.1.1; do sleep 2; done;
cd /home/vugia || exit
curl ntfy.sh \
    -d '{
        "topic": "momoin_vip",
        "message": "cronjob start please keep your pc awake!",
        "title": "Home-vugia Backup",
        "tags": ["warning"],
        "priority": 4
    }'
pgpgram --version || exit
tar -I 'zstd -T2 -7' -cpf /media/WD_Black_1TB/Backup/home-vugia-$(date '+%Y-%m-%d').tar.zst \
    .local/share/bottles/*.yml \
    --exclude-backups \
    --exclude-from=/home/vugia/scripts/exclude_file.txt .

cd /media/WD_Black_1TB/Backup/ || exit
pgpgram backup --size 1000 ./*.zst && /bin/rm -f ./*.zst
/bin/rm -f /home/vugia/.cache/pgpgram/*
curl -H "Title: Home-Vugia Backup" -H "Priority: urgent" -H "Tags: warning" -d "Finished" ntfy.sh/momoin_vip
