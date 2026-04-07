#!/bin/bash
# Bash Menu Script Example

PS3='Select games: '
options=("DOS2" "Subnautica" "Kenna" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "DOS2")
            firejail --net=none --noprofile bottles-cli run -p 'Divinity: Original Sin 2 - Definitive Edition' -b 'Game'
            ;;
        "Subnautica")
            offline bottles-cli run -p Subnautica -b 'Game'
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
