mkdir -p "$HOME"/podman/appdata/servarr/navidrome
podman run --replace -d --network momonet --label io.containers.autoupdate=registry \
    --name navidrome \
    -v "$HOME"/momopod/appdata/servarr/navidrome:/data \
    -v /media/HDD500/servarr/media/music:/music/music \
    -v /media/HDD500/media/Muzik:/music/Muzik \
    -e ND_LOGLEVEL=info \
    docker.io/deluan/navidrome:latest