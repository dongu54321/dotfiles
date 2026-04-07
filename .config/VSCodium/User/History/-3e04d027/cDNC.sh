cd /home/vugia/podman
echo "Trilium:16600"
podman run --replace -d --label "io.containers.autoupdate=registry" \
    --name=trilium -p 16600:8080 \
    -e "USER_UID=1001" -e "USER_GID=1001" \
    -v ./appdata/trilium:/home/node/trilium-data \
    docker.io/zadam/trilium
    