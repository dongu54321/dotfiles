#!/bin/bash
cd ~/momopod/scripts
OLD_IP=$(cat ip.txt)
NEW_IP=$(ip -6 addr show dev "eno1" |grep 'global'| sed -e 's!.*inet6 \([^ ]*\)\/.*$!\1!;t;d' | grep -v '^fc' | grep -v '^fd00' | grep -v '^fe80' | grep -v '^fdc0' | head -1)
#NEW_IP=$(curl -6 --retry 20 --retry-delay 5 -s https://api64.ipify.org)

if test "$OLD_IP" = "$NEW_IP"; then
	echo "IP has not changed"
else
	echo "IP has changed"
	echo $NEW_IP > ip.txt
	podman run -d --rm --replace --name seleniumfirefox --net=host -p 4444:4444 -p 7900:7900 --shm-size="2g" selenium/standalone-firefox:4.11.0-20230801
	sleep 5
	/bin/bash -c "source /home/momo/momopod/scripts/venv/bin/activate; python slenium_autoip6.py"
	# sudo ip addr del 192.168.1.64/24 dev enp0s3
	# sleep 5
	# yunohost dyndns update --force
	# sudo ip addr add 192.168.1.64/24 dev enp0s3
	# sudo ifdown enp0s3
	# sudo ifup enp0s3
	#killall firefox-esr
	podman stop seleniumfirefox
	#until ping -c1 9.9.9.9; do sleep 1; done;
	curl -s --retry 20 --retry-delay 5 --retry-all-errors "https://www.duckdns.org/update?domains=momoin&token=6fec108e-f354-412d-8ed6-ae99e40e9209&ip=100.64.0.4&ipv6=$NEW_IP&verbose=true"
	#curl -s "https://www.duckdns.org/update?domains=momoin&token=6fec108e-f354-412d-8ed6-ae99e40e9209&ip=100.64.0.4&ipv6=$NEW_IP&verbose=true"
    curl -H "Title: ipv6 on momoin changed to" -H "Priority: urgent" -H "Tags: warning" -d "$NEW_IP" ntfy.sh/momoin
fi

# NEW_IP=2402:800:61cd:f977:d6be:d9ff:fe69:4b7c
# curl -s "https://www.duckdns.org/update?domains=momoin&token=6fec108e-f354-412d-8ed6-ae99e40e9209&ip=&ipv6=$NEW_IP&verbose=true"

#curl -s --retry 20 --retry-delay 5 --retry-all-errors "https://www.duckdns.org/update?domains=moinin&token=6fec108e-f354-412d-8ed6-ae99e40e9209&ip=100.64.0.4&ipv6=$(ip -6 addr show dev "eno1" |grep 'scope global temporary dynamic'| sed -e 's!.*inet6 \([^ ]*\)\/.*$!\1!;t;d' | grep -v 'fe69:4b7c/64' | grep -v '^fc' | grep -v '^fd00' | grep -v '^fe80' | grep -v '^fdc' | head -1)&verbose=true"