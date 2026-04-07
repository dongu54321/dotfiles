#!/bin/bash
cd /home/dragon/momopod/appdata/caddy || exit

echo pulling images pls be patient
podman pull -q docker.io/library/caddy