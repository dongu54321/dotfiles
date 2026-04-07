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
            podman stop --all --time 10
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
#curl -s "https://www.duckdns.org/update?domains=moinin&token=6fec108e-f354-412d-8ed6-ae99e40e9209&ip=&ipv6=$(ip -6 addr show dev "eno1" | grep  'global'| sed -e 's!.*inet6 \([^ ]*\)\/.*$!\1!;t;d' | grep -v '^fc' | grep -v '^fd00' | grep -v '^fe80' | head -1)&verbose=true" 