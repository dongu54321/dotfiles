#!/bin/bash
# Bash Menu Script Example

PS3='Please enter your choice: '
options=("Trilium Notes" "Homepage" "Option 3" "Stop ALL" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Trilium Notes")
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
            podman stop -a --time 10
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
