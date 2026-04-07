#!/usr/bin/env bash
mkdir -p ~/momopod/appdata/adguard/{certs,conf,data}
podman run --replace -d --net=host --label io.containers.autoupdate=registry \
    --name adguard \
    --dns=9.9.9.9 \
    -v ~/momopod/appdata/adguardhost/conf:/opt/adguardhome/conf \
    -v ~/momopod/appdata/adguardhost/data:/opt/adguardhome/work \
    -v ~/momopod/dehydrated/certs/momoin_duckdns_org:/opt/adguardhome/certs:ro \
docker.io/adguard/adguardhome