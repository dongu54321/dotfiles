#!/bin/bash
# Run by /home/vugia/.config/systemd/user/weekly_maintain.service weekly
# update arkenfox user-js
/home/vugia/arkenfox-userjs/updater.sh -usb

# Update zsh plugin
zinit update --all --quite

# youtube-local update
git -C /media/WD_Black_1TB/Download/Portable-Programs/youtube-local pull

# agh copy conf to note 9
# ssh n9-qemu killall AdGuardHome
# scp momo-dell6430:/home/momo/momopod/app/adguardhome/conf/AdGuardHome.yaml n9-qemu:/root/AdguardHome
# ssh n9-qemu rc-service AdGuardHome start
