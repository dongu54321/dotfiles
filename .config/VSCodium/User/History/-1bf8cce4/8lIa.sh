TELEGRAM_TOKEN=6663320749:AAGusqcmfr4qXPmODvoRU2pOuSHNKvHYw2I
TELEGRAM_CHATID=6307708008
NAME=$(hostname | tr '[a-z]' '[A-Z]')
apiid=25639628
apihash=c546fc73d8ce3dc31190f7cd9e93bc3b

#cat sonarr*.tar.zst.gpg.* | gpg -d --batch --passphrase MoMo6789 | tar -I zstd -xvf -

curl -H "Title: Backup Starts!" -H "Priority: urgent" -H "Tags: warning" -d "momoin" ntfy.sh/momoin

tar_backup(){
    #systemctl --user stop container-$d.service
    filename=$1-$(date '+%Y-%m-%d')
    echo creating backup $filename.tar.zst.gpg
    tar -I zstd -cvpf - $1 --exclude-caches| gpg -o- -c --batch --passphrase MoMo6789 | split -d -b 2000m - $filename.tar.zst.gpg.
    #echo Done container-$1.service
    #systemctl --user status container-$name.service
}

tar_backup_1(){
    systemctl --user stop container-$1.service
    filename=$1-$(date '+%Y-%m-%d')
    echo creating backup $filename.zst
    tar -I zstd -cvpf - $1 --exclude-caches | gpg -o- -c --batch --passphrase MoMo6789 | split -d -b 2000m - $filename.tar.zst.gpg.
    #echo Done container-$1.service
    systemctl --user start container-$1.service
}

tar_backup_1_(){
    systemctl --user stop $1.service
    filename=$1-$(date '+%Y-%m-%d')
    echo creating backup $filename.zst
    tar -I zstd -cvpf - $1 --exclude-caches | gpg -o- -c --batch --passphrase MoMo6789 | split -d -b 2000m - $filename.tar.zst.gpg.
    #echo Done container-$1.service
    systemctl --user start $1.service
}

send_backup(){
    for f in ./*.tar.zst.gpg.*
    do
        curl --silent http://127.0.0.1:8081/bot$TELEGRAM_TOKEN/sendDocument \
            -F document=@"$f" -F chat_id=$TELEGRAM_CHATID \
            -F caption=$NAME > /dev/null
        #rm -f $f
    done
}

#nohup /home/momo/.local/bin/telegram-bot-api --api-id=$apiid --api-hash=$apihash > /dev/null &
podman run -d --rm --replace -p 8081:8081 --name=telegram-bot-api \
    -v telegram-bot-api-data:/var/lib/telegram-bot-api \
    -e TELEGRAM_API_ID=25639628 \
    -e TELEGRAM_API_HASH=c546fc73d8ce3dc31190f7cd9e93bc3b \
docker.io/aiogram/telegram-bot-api:latest

cd /home/momo/momopod/appdata/
#adguardhome
#tar_backup_1 adguard
#agh
# systemctl --user stop adguardhome.service
# tar_backup agh
# systemctl --user start adguardhome.service
#adguardhost
tar_backup_1 adguardhost
#Homepage
tar_backup_1 homepage
#caddy
tar_backup_1 caddy
#Changedetection
tar_backup_1 changedetection
#searxng
tar_backup_1 searxng
#trilium
tar_backup_1 trilium
#homarr
tar_backup_1 homarr
#vaulwarden
tar_backup_1 vaultwarden
#babybuddy


#wallabag
systemctl --user stop container-wallabag-db.service container-wallabag.service
tar_backup wallabag
systemctl --user start container-wallabag-db.service container-wallabag.service
#nextcloud
# systemctl --user stop container-nextcloud_cron_1.service \
#     container-nextcloud-db.service container-nextcloud-redis.service \
#     container-nextcloud.service
# tar_backup nextcloud
# systemctl --user start container-nextcloud_cron_1.service \
#     container-nextcloud-db.service container-nextcloud-redis.service \
#     container-nextcloud.service

cd /home/momo/momopod/app
tar_backup_1_ babybuddy

podman exec -t immich-postgres14 pg_dumpall -c -U immich_user_2023  > "./dump2.sql"
tar -I zstd -cvpf - dump2.sql | gpg -o- -c --batch --passphrase MoMo6789 | split -d -b 2000m - dump2sql.tar.zst.gpg.
rm -f ./dump2.sql
#podman exec -t immich-postgres14 pg_dumpall -c -U immich_user_2023 | tar -I zstd -c - -T | gpg -o- -c --batch --passphrase MoMo6789 | split -d -b 2000m - dump2sql.tar.zst.gpg.

sleep 5
send_backup
rm -f ./*.tar.zst.gpg.*

cd /home/momo/momopod
cp /home/momo/momopod/.bashrc /home/momo/momopod/scripts/
cp -r /home/momo/.config/systemd/user /home/momo/momopod/scripts/systemd/
tar_backup scripts
send_backup
rm -f ./*.tar.zst.gpg.*

####servarr app
cd /home/momo/momopod/appdata/servarr
#systemctl --user start container-jellyfin.service container-bazarr.service container-lidarr.service container-lidarr2.service container-navidrome.service container-prowlarr.service container-radarr.service container-sonarr.service container-qbittorrent.service
tar_backup_1 jellyfin
tar_backup_1 bazarr
#tar_backup_1 lidarr
tar_backup_1 lidarr2
#tar_backup_1 navidrome
tar_backup_1 prowlarr
tar_backup_1 radarr
tar_backup_1 sonarr
tar_backup_1 qbittorrent
send_backup
rm -f ./*.tar.zst.gpg.*

#systemd files
# cd
# tar_backup user
# send_backup
# rm -f ./*.tar.zst.gpg.*

curl -H "Title: Backup Complete\!" -H "Priority: urgent" -H "Tags: warning" -d "momoin Check telegram" ntfy.sh/momoin

podman stop telegram-bot-api