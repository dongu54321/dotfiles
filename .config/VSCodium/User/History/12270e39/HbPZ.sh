#!/bin/
#loop throuh files
for i in /etc/*.conf; do cp "$i" /backup; done

for i in $(pgpgram list | grep 20231106); do pgpgram restore $i; done

# cat from file to file append
cat ~/.ssh/debian-dell.pub | sudo tee -a /home/momo/.ssh/authorized_keys >/dev/null
###Get current_date
current_date=$(date +"%Y-%m-%d_%H:%M")
