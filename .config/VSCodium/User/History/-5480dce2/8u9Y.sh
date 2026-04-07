sudo apt update && apt install curl
curl -fsSL https://tailscale.com/install.sh | sudo sh
sudo tailscale up --login-server https://wg.momo.nohost.me/