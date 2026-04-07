#!/bin/bash
# Bash Menu Script Example
shopt -s expand_aliases
alias offline='firejail --net=none --noprofile'
proton='/media/Nvme_Data/proton/GE-Proton7-41/proton'
PS3='Select games: '
options=("IronHarvest" "DOS2" "Subnautica" "Kenna" "Farthest Frontier" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "IronHarvest")
            cd /media/Nvme_Data/Games/Iron\ Harvest/release
            SteamAppId=826630 STEAM_COMPAT_DATA_PATH=/media/Nvme_Data/proton/compatdata/ \
            STEAM_COMPAT_CLIENT_INSTALL_PATH=/ offline $proton waitforexitandrun IronHarvest.exe
            ;;
        "Subnautica")
            cd /media/Nvme_Data/Games/Subnautica.v70659/
            SteamAppId=264710 STEAM_COMPAT_DATA_PATH=/media/Nvme_Data/proton/compatdata/ \
            STEAM_COMPAT_CLIENT_INSTALL_PATH=/ offline $proton waitforexitandrun Subnautica.exe
            ;;
        "Farthest Frontier")
            cd /media/Nvme_Data/Games/Farthest\ Frontier/
            SteamAppId=1044720 STEAM_COMPAT_DATA_PATH=/media/Nvme_Data/proton/compatdata/ \
            STEAM_COMPAT_CLIENT_INSTALL_PATH=/ offline $proton waitforexitandrun Farthest\ Frontier.exe
            ;;
        "Kenna")
            offline bottles-cli run -p Kena -b "Game"
            ;;
        "Daysgone")
            firejail --net=none --noprofile bottles-cli run -p DaysGone -b 'Game'
            ;;  
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
