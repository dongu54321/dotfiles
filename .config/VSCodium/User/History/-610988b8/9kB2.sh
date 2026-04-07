#!/bin/bash
# Bash Menu Script Example

PS3='Select games: '
options=("DOS2" "Subnautica" "Kenna" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "DOS2")
            #podman stop trilium
            podman start trilium
            ;;
        "Homepage")
            podman start homepage
            ;;
        "Option 3")
            echo "you chose choice $REPLY which is $opt"
            ;;
        "Quit")
            break
            ;;
        "Stop ALL")
            podman stop --all --time 10
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
