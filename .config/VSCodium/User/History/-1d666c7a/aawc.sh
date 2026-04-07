#!/bin/bash
# update arkenfox user-js
/home/vugia/arkenfox-userjs/updater.sh -usb

# Update zsh plugin
zinit update --all --quite

# youtube-local update
git -C /media/WD_Black_1TB/Download/Portable-Programs/youtube-local fetch