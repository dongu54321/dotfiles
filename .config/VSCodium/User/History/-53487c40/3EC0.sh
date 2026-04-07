# termux folder (remove if you aren't using proot-distro)
export PREFIX=/data/data/com.termux/files/usr

qemu-system-x86_64 -machine q35 -m 1024 -smp cpus=2 --accel tcg,thread=multi \
  -drive if=pflash,format=raw,read-only=on,file=$PREFIX/share/qemu/edk2-x86_64-code.fd \
  -netdev user,id=n1,hostfwd=tcp::2222-:22,net=192.168.50.0/24,hostfwd=tcp::443-:443,hostfwd=tcp::80-:80,hostfwd=udp::53-:53,hostfwd=udp::443-:443,hostfwd=tcp::8086-:8086 \
  -device virtio-net,netdev=n1 \
  -nographic alpine.img
