#!/bin/bash
# Bash Menu Script Example

PS3='Please enter your choice: '
options=("Trilium Notes" "Homepage" "Option 3" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Trilium Notes")
            podman stop trilium
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
        *) echo "invalid option $REPLY";;
    esac
done
