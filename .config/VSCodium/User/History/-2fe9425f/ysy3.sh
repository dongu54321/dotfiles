#!/bin/bash
# Bash Menu Script Example
alias offline='firejail --net=none --noprofile'
PS3='Select games: '
options=("DOS2" "Subnautica" "Kenna" "Farthest Frontier" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "DOS2")
            offline bottles-cli run -p 'Divinity: Original Sin 2 - Definitive Edition' -b 'Game'
            ;;
        "Subnautica")
            cd /media/Nvme_Data/Games/Subnautica.v70659/
            SteamAppId=264710 STEAM_COMPAT_DATA_PATH=/media/Nvme_Data/proton/compatdata/ STEAM_COMPAT_CLIENT_INSTALL_PATH=/ offline /media/Nvme_Data/proton/GE-Proton7-41/proton waitforexitandrun Subnautica.exe
            ;;
        "Kenna")
            offline bottles-cli run -p Kena -b "Game"
            ;;
        "Daysgone")
            firejail --net=none --noprofile bottles-cli run -p DaysGone -b 'Game'
            ;;  
        "Farthest Frontier")
            cd /media/Nvme_Data/Games/Farthest\ Frontier/
            SteamAppId=1044720 STEAM_COMPAT_DATA_PATH=/media/Nvme_Data/proton/compatdata/ STEAM_COMPAT_CLIENT_INSTALL_PATH=/ offline /media/Nvme_Data/proton/GE-Proton7-41/proton waitforexitandrun Farthest\ Frontier.exe
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
