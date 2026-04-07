#!/usr/bin/env bash
mkdir -p ~/momopod/appdata/caddy/{etc-caddy,site,caddy_data,caddy_config}
podman run --replace -d --network=host --name caddy --label io.containers.autoupdate=registry \
    --restart always \
    -p 80:80 -p 443:443 -p 443:443/udp \
    -v ~/momopod/appdata/caddy/etc-caddy:/etc/caddy:rw \
    -v /etc/localtime:/etc/localtime:ro \
    -v ~/momopod/appdata/caddy/site:/srv:rw \
    -v ~/momopod/appdata/caddy/caddy_data:/data:rw \
    -v ~/momopod/appdata/caddy/caddy_config:/config:rw \
docker.io/library/caddy
