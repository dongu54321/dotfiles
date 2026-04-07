#!/bin/bash
# Bash Menu Script Example

PS3='Select games: '
options=("RimWorld" "IronHarvest" "DOS2" "Subnautica" "Kenna" "Farthest Frontier" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "RimWorld")
            firejail --net=none --noprofile /media/Nvme_Data/Games/Rimworld-jc141/files/groot/RimWorldLinux
            ;;

        "IronHarvest")
            firejail --net=none --noprofile bottles-cli run -p 'IronHarvest' -b 'Game'
            ;;

        "DOS2")
            firejail --net=none --noprofile bottles-cli run -p 'Divinity: Original Sin 2 - Definitive Edition' -b 'Game'
            ;;
        "Subnautica")
            firejail --net=none --noprofile bottles-cli run -p Subnautica -b 'Game'
            ;;
        "Kenna")
            firejail --net=none --noprofile bottles-cli run -p Kena -b "Game"
            ;;
        "Daysgone")
            firejail --net=none --noprofile bottles-cli run -p DaysGone -b 'Game'
            ;;
        "Farthest Frontier")
            firejail --net=none --noprofile bottles-cli run -p 'Farthest Frontier' -b 'Game'
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;

    esac
done
