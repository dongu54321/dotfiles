#!/usr/bin/env bash
podman network create --ignore --subnet 192.16.0.1/16 momonet

podmansystemd() {
	cd ~/.config/systemd/user/
	podman generate systemd --name --files --new $1
	systemctl --user daemon-reload
    podman stop $1
	systemctl --user enable --now container-$1.service
    cd -
}
# Caddy
cd ~/momopod
mkdir -p ~/momopod/appdata/caddy/{container-config,site,caddy_data,caddy_config}
mkdir -p ~/momopod/appdata/trilium
mkdir -p ~/momopod/appdata/searxng

#cd /home/momo/momopod/appdata/caddy/
#podman build -t caddy-duckdns:lastest .
podman run --replace -d --network momonet --name caddy \
    --network-alias caddy \
    -p 80:80 -p 443:443 -p 443:443/udp \
    -v ~/momopod/appdata/caddy/container-config:/etc/caddy:rw \
    -v /etc/localtime:/etc/localtime:ro \
    -v ~/momopod/appdata/caddy/site:/srv:rw \
    -v ~/momopod/appdata/caddy/caddy_data:/data:rw \
    -v ~/momopod/appdata/caddy/caddy_config:/config:rw \
    -v ~/momopod/dehydrated/certs/momoin_duckdns_org:/data/ssl:ro \
docker.io/library/caddy
podmansystemd caddy
#######################################################################
#Trilium 8080
podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name=trilium \
    --network-alias trilium --user 0:0 --userns=keep-id:uid=1000,gid=1000 \
    -v ~/momopod/appdata/trilium:/home/node/trilium-data \
docker.io/zadam/trilium
podmansystemd trilium
#######################################################################
# SearchXNG 8080
podman run  --replace -d --network momonet --label io.containers.autoupdate=registry --name=searxng \
    --network-alias searxng \
    -v ~/momopod/appdata/searxng:/etc/searxng:rw \
    --cap-drop ALL --cap-add CHOWN --cap-add SETGID --cap-add SETUID --cap-add DAC_OVERRIDE \
    --log-driver json-file  --log-opt max-size=1m --log-opt max-file=1 \
    -e "BASE_URL=https://searx.momoin.duckdns.org/" \
    -e "INSTANCE_NAME=MoMoIn-SearchXNG" \
    docker.io/searxng/searxng
podmansystemd searxng
#######################################################################
#changedetect 5000
mkdir -p ~/momopod/appdata/changedetection
podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name changedetect \
    --network-alias changedetect \
    -v ~/momopod/appdata/changedetection:/datastore:rw \
docker.io/dgtlmoon/changedetection.io
podmansystemd changedetect
#######################################################################
#Whoogle 16613
mkdir -p ~/momopod/appdata/whoogle
podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name whoogle \
    --network-alias whoogle \
    -e WHOOGLE_ALT_RD=https://reddit.momoin.duckdns.me \
    -e WHOOGLE_ALT_YT=https://youtube.momoin.duckdns.me \
docker.io/benbusby/whoogle-search:latest
podmansystemd whoogle
#######################################################################
#adguardhome 53:53/tcp53 853 80 443 3000 443/tcp 443/udp\
mkdir -p ~/momopod/appdata/adguard/{conf,data,certs}
podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name adguard \
    --network-alias adguard \
    --dns=9.9.9.9 \
    -v ~/momopod/appdata/adguard/conf:/opt/adguardhome/conf \
    -v ~/momopod/appdata/adguard/data:/opt/adguardhome/work \
    -v ~/momopod/dehydrated/certs/momoin_duckdns_org:/opt/adguardhome/certs:ro \
docker.io/adguard/adguardhome
podmansystemd adguard
#adguardhost
mkdir -p ~/momopod/appdata/adguardhost/{conf,data,certs}
podman run --replace -d --net=host --label io.containers.autoupdate=registry \
    --name adguardhost \
    --dns=9.9.9.9 \
    -v ~/momopod/appdata/adguardhost/conf:/opt/adguardhome/conf \
    -v ~/momopod/appdata/adguardhost/data:/opt/adguardhome/work \
    -v ~/momopod/dehydrated/certs/momoin_duckdns_org:/opt/adguardhome/certs:ro \
docker.io/adguard/adguardhome
podmansystemd adguardhost
#######################################################################
#libreddit -p 8080:8080
podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name libreddit docker.io/libreddit/libreddit
podmansystemd libreddit
#######################################################################
#Upime-Kuma -p 3001:3001
mkdir -p ~/momopod/appdata/kuma && cd ~/momopod
podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name kuma \
    -v ~/momopod/appdata/kuma:/app/data \
docker.io/louislam/uptime-kuma:1
podmansystemd kuma
#######################################################################
#Vaultwarden 80
podman run --replace -d --network momonet --label io.containers.autoupdate=registry	--name=vaultwarden \
	-e SIGNUPS_ALLOWED=false \
	-e DOMAIN='https://vault.momoin.duckdns.org/' \
	-e ADMIN_TOKEN='tZ1z0y6L2YX47waUcgA8zpOFVH6auCztItKZquDjjL' \
	-v /home/momo/momopod/appdata/vaulwarden/data:/data/ \
	--network-alias vaultwarden quay.io/vaultwarden/server:latest
#######################################################################
#Wallabag 80 wallabag/wallabag
podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name wallabag-db \
    --user 0:0 --userns=keep-id:uid=999,gid=999 \
    -e MYSQL_ROOT_PASSWORD=wallarootmomoin \
    -v /home/momo/momopod/appdata/test-compose/wallabag/data:/var/lib/mysql \
docker.io/mariadb

podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name wallabag \
    --requires=wallabag-db \
    -e MYSQL_ROOT_PASSWORD=wallarootmomoin \
    -e SYMFONY__ENV__DATABASE_DRIVER=pdo_mysql \
    -e SYMFONY__ENV__DATABASE_HOST=wallabag-db \
    -e SYMFONY__ENV__DATABASE_PORT=3306 \
    -e SYMFONY__ENV__DATABASE_NAME=wallabag \
    -e SYMFONY__ENV__DATABASE_USER=wallabagmomoin \
    -e SYMFONY__ENV__DATABASE_PASSWORD=wallapassmomoin \
    -e SYMFONY__ENV__DATABASE_CHARSET=utf8mb4 \
    -e SYMFONY__ENV__MAILER_DSN=smtp://vugia:password@@momo.nohost.me:587 \
    -e SYMFONY__ENV__FROM_EMAIL=wallabag@momoin.duckdns.org \
    -e SYMFONY__ENV__DOMAIN_NAME=https://wallabag.momoin.duckdns.org \
    -e SYMFONY__ENV__SERVER_NAME="Momoin" \
    -v /home/momo/momopod/appdata/test-compose/wallabag/images:/var/www/wallabag/web/assets/images \
docker.io/wallabag/wallabag
#######################################################################
#Nextcloud
#podman pod create --name=pod_nextcloud --share=
podman network create --ignore nextcloud_default
#   nextcloud-db
podman run --rm -d --replace --name=nextcloud-db \
    --user 0:0 --userns=keep-id:uid=999,gid=999 \
	-e MYSQL_ROOT_PASSWORD=nextcloud \
	-e MYSQL_PASSWORD=nextcloud \
	-e MYSQL_DATABASE=nextcloud \
	-e MYSQL_USER=nextcloud \
	-e MARIADB_AUTO_UPGRADE=1 \
	-e MARIADB_DISABLE_UPGRADE_BACKUP=1 \
	-v /home/momo/momopod/appdata/nextcloud/nextcloud-db:/var/lib/mysql:z \
	--net nextcloud_default \
	--network-alias nextcloud-db docker.io/library/mariadb \
	--transaction-isolation=READ-COMMITTED \
	--binlog-format=ROW
#   nextcloud-redis
podman run --rm -d --replace --name=nextcloud-redis \
    --user 0:0 --userns=keep-id:uid=999,gid=1000 \
	-e TZ=Asia/HoChiMinh \
	-v /home/momo/momopod/appdata/nextcloud/redis:/data:z \
	--net nextcloud_default \
	--network-alias nextcloud-redis docker.io/library/redis:alpine redis-server \
	--requirepass nextcloud
#   nextcloud_cron_1
podman run --rm -d --replace --name=nextcloud_cron_1 \
    --user 0:0 --userns=keep-id:uid=33,gid=33 \
	-v /home/momo/momopod/appdata/nextcloud/nextcloud:/var/www/html:z \
	--net nextcloud_default \
	--network-alias cron \
	--entrypoint "[\"/cron.sh\"]" docker.io/library/nextcloud
#   nextcloud_main_app
podman run --rm -d --replace --name=nextcloud \
    --requires=nextcloud-db,nextcloud-redis \
    --user 0:0 --userns=keep-id:uid=33,gid=33 \
	-e MYSQL_PASSWORD=nextcloud \
	-e MYSQL_DATABASE=nextcloud \
	-e MYSQL_USER=nextcloud \
	-e MYSQL_HOST=nextcloud-db \
	-e TRUSTED_PROXIES=cloud.momoin.duckdns.org \
	-e OVERWRITEPROTOCOL=https \
	-e OVERWRITEHOST=cloud.momoin.duckdns.org \
	-e REDIS_HOST=nextcloud-redis \
	-e REDIS_HOST_PASSWORD=nextcloud \
	-v /home/momo/momopod/appdata/nextcloud/nextcloud:/var/www/html:z \
	--net momonet,nextcloud_default \
	--network-alias nextcloud docker.io/library/nextcloud
#-v /media/HDD500/nextcloud:/var/www/html/data:z \
podman  exec -t -u www-data nextcloud php -f /var/www/html/cron.php
podman  exec -t -u www-data nextcloud php occ config:system:set default_phone_region --value 'VN'

#systemctl --user enable --now container-nextcloud-redis.service container-nextcloud-db.service container-nextcloud_cron_1.service container-nextcloud.service
#systemctl --user disable --now container-nextcloud-redis.service container-nextcloud-db.service container-nextcloud_cron_1.service container-nextcloud.service
#######################################################################
#homepage 3000
mkdir -p /home/momo/momopod/appdata/homepage
podman run --replace --rm -d --network momonet --label io.containers.autoupdate=registry \
    --name homepage \
    -v /home/momo/momopod/appdata/homepage:/app/config \
    -v /home/momo/momopod/appdata/homepage/images:/app/public/images
ghcr.io/benphelps/homepage:latest

#################SERVARR
mkdir -p ~/momopod/appdata/servarr/{jellyfin,radarr,sonarr,whisparr,prowlarr,qbittorrent,bazarr}
# jellyfin 8096
#######################################################################
podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name jellyfin \
    --security-opt no-new-privileges:true \
    --user 0:0 --userns=keep-id:uid=911,gid=911 \
    -e TZ=Asia/Ho_Chi_Minh \
    -v ~/momopod/appdata/servarr/jellyfin/:/config \
    -v /media/HDD500/servarr/media:/servarr/media \
    -v /media/HDD500/servarr/torrents/jav:/servarr/torrents/jav \
lscr.io/linuxserver/jellyfin
#######################################################################
#radarr 7878 Movies
podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name radarr \
    --user 0:0 --userns=keep-id:uid=911,gid=911 \
    -e TZ=Asia/Ho_Chi_Minh \
    -v ~/momopod/appdata/servarr/radarr:/config \
    -v /media/HDD500/servarr:/servarr \
lscr.io/linuxserver/radarr
#######################################################################
#sonarr 8989 Series
podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name sonarr \
    --user 0:0 --userns=keep-id:uid=911,gid=911 \
    -e TZ=Asia/Ho_Chi_Minh \
    -v ~/momopod/appdata/servarr/sonarr:/config \
    -v /media/HDD500/servarr:/servarr \
lscr.io/linuxserver/sonarr
#######################################################################
#whisparr 8989 borno
podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name whisparr \
    --user 0:0 --userns=keep-id:uid=1000,gid=1000 \
    -e TZ=Asia/Ho_Chi_Minh \
    -v ~/momopod/appdata/servarr/whisparr:/config \
    -v /media/HDD500/servarr:/servarr \
cr.hotio.dev/hotio/whisparr
#######################################################################
#bazarr 6767 Subtitles
podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name bazarr \
    --user 0:0 --userns=keep-id:uid=911,gid=911 \
    -e TZ=Asia/Ho_Chi_Minh \
    -v ~/momopod/appdata/servarr/bazarr:/config \
    -v /media/HDD500/servarr/media:/servarr/media \
lscr.io/linuxserver/bazarr
#######################################################################
#prowlarr 9696 Indexers
podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name prowlarr \
    --user 0:0 --userns=keep-id:uid=911,gid=911 \
    -e TZ=Asia/Ho_Chi_Minh \
    -v ~/momopod/appdata/servarr/prowlarr:/config \
lscr.io/linuxserver/prowlarr
#######################################################################
# qbittorrent 8080 admin/adminadmin
podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name qbittorrent \
    --user 0:0 --userns=keep-id:uid=1000,gid=1000 \
    -e TZ=Asia/Ho_Chi_Minh \
    -e UMASK=002 \
    -v ~/momopod/appdata/servarr/qbittorrent:/config \
    -v /media/HDD500/servarr/torrents:/servarr/torrents \
cr.hotio.dev/hotio/qbittorrent
#######################################################################
#Navidrome #   --user $(id -u):$(id -g) \    -p 4533:4533 \
mkdir -p "$HOME"/momopod/appdata/servarr/navidrome
podman run --replace -d --network momonet --label io.containers.autoupdate=registry \
    --name navidrome \
    -v "$HOME"/momopod/appdata/servarr/navidrome:/data \
    -v /media/HDD500/servarr/media/music:/music/music \
    -v /media/HDD500/media/Muzik:/music/Muzik \
    -e ND_LOGLEVEL=info \
    docker.io/deluan/navidrome:latest
#######################################################################
#Homarr 7575
# -e PASSWORD=homarr-caddy-0132-always-in-mylove-6789 \
mkdir -p "$HOME"/momopod/appdata/homarr/{configs,icons}
podman run --replace -d --network momonet --label io.containers.autoupdate=registry \
    --name homarr \
    -v "$HOME"/momopod/appdata/homarr/configs:/app/data/configs \
    -v "$HOME"/momopod/appdata/homarr/icons:/app/public/icons \
    -p 127.0.0.1:7575:7575 \
ghcr.io/ajnart/homarr:0.13.2


#######################################################################

curl -s --retry 20 --retry-delay 5 --retry-all-er  rors "https://www.duckdns.org/update?domains=moinin&token=6fec108e-f354-412d-8ed6-ae99e40e9209&ip=100.64.0.1&ipv6=$(ip -6 addr show dev "eno1" |grep 'scope global temporary dynamic'| sed -e 's!.*inet6 \([^ ]*\)\/.*$!\1!;t;d' | grep -v 'fe69:4b7c/64' | grep -v '^fc' | grep -v '^fd00' | grep -v '^fe80' | grep -v '^fdc' | head -1)&verbose=true"

#Bookstacklibdb 16614
# mkdir -p ~/momopod/appdata/bookstack/bookstack_db
# podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name=bookstack_db \
#     --network-alias bookstack_db \
#     -e PUID=$(id -u) -e PGID=$(id -g) -e TZ=Asia/Ho_Chi_Minh \
#     -e MYSQL_ROOT_PASSWORD=momo_mysql_root_mk \
#     -e MYSQL_DATABASE=bookstackapp -e MYSQL_USER=bookstack \
#     -e MYSQL_PASSWORD=momodb_pass_bookstack \
#     -v ~/momopod/appdata/bookstack/bookstack_db:/config \
#     lscr.io/linuxserver/mariadb
# Bookstack 80
# podman run --replace -d --network momonet --label io.containers.autoupdate=registry --name=bookstack \
#     --network-alias bookstack \
#     -e PUID=$(id -u) -e PGID=$(id -g) -e TZ=Asia/Ho_Chi_Minh \
#     -e APP_URL=https://bookstack.momoin.duckdns.org \
#     -e DB_HOST=bookstack_db -e DB_USER=bookstack \
#     -e DB_PASS=momodb_pass_bookstack -e DB_DATABASE=bookstackapp \
#     -v ~/momopod/appdata/bookstack:/config \
#     --requires bookstack_db \
#     lscr.io/linuxserver/bookstack
