function ufwdel
    for i in $argv[1] $argv[2] $argv[3] $argv[4];
    do
        yes | ufw delete "$i";
    end
end

function podmansystemd

    podman generate systemd --name --new "$argv[1]" > ~/.config/systemd/user/container-"$argv[1]".service;
    systemctl --user daemon-reload;
    podman rm -f $argv[1];
    systemctl --user enable --now container-"$argv[1]".service
end

function rimdown
    /media/Nvme_Data/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/steamcmd.sh +force_install_dir /media/Nvme_Data/Games/workshop/ +login anonymous +workshop_download_item 294100 $argv[1] +exit
end

function steamdown
    /media/Nvme_Data/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/steamcmd.sh +force_install_dir /media/Nvme_Data/Games/workshop/ +login anonymous +workshop_download_item $argv[1] $argv[2] +exit
end

function tarscp_from_remote
    if [ (count $argv) -ne 3 ]
        echo "Usage: tarscp_from_remote remote_host remote_dir local_dir" 1>&2;
        return;
    end
    ssh "$argv[1]" "tar -C $argv[2] -cf - ./" | tar -C "$argv[3]" -xf -
end

function tarscp_to_remote
    if [ (count $argv) -ne 3 ]
        echo "Usage: tarscp_to_remote local_dir_pathend remote_hostend remote_dir_pathend" 1>&2;
        return;
    end
    tar -C "$argv[1]" -cf - ./ | ssh "$argv[2]" "tar -C $argv[3] -xf -"
end

function tarscp_from_remote_xz
    if [ (count $argv) -ne 3 ]
        echo "Usage: tarscp_from_remote_xz remote_hostend remote_dir_pathend local_dir_pathend" 1>&2;
        return;
    end
    ssh "$argv[1]" "tar -C $argv[2] -Jcf - ./" | tar -C "$argv[3]" -Jxf -
end

function tarscp_to_remote_xz
    if [ (count $argv) -ne 3 ]
        echo "Usage: tarscp_to_remote_xz local_dir_pathend remote_hostend remote_dir_pathend" 1>&2;
        return;
    end
    tar -C "$argv[1]" -Jcf - ./ | ssh "$argv[2]" "tar -C $argv[3] -Jxf -"
end

function _acl
    if [ (count $argv) -ne 2 ]
        echo "Usage: _acl <user> <folder>" 1>&2;
        return;
    end
    set user=$argv[1];
    set folder=$argv[2];
    sudo setfacl -Rm u:"$user":rwx "$folder";
    sudo setfacl -Rm d:u:"$user":rwx "$folder"
end

function nebula_add_host

    cd ~/scripts/nebula || exit;
    set hostname $argv[1]
    set nebulaip=$argv[2]
    set group=$argv[3]
    set lanip=$argv[4]
    echo "$hostname $nebulaip $group $lanip"
    if [ -d "cert/$group/$hostname" ]
        echo "WARM cert exist skipping !"
    else
        nebula-cert sign -name "$hostname" -ip "$nebulaip/12" -groups "$group"
        mkdir -p "cert/$group/$hostname"
        cp ca.crt "cert/$group/$hostname"
        cp config.yaml "cert/$group/$hostname"
        cp nebula.service "cert/$group/$hostname"
        mv "$hostname".crt "cert/$group/$hostname"/host.crt
        mv "$hostname".key "cert/$group/$hostname"/host.key
    end

    cp install.sh "cert/$group/$hostname"
    set FILE=$HOME/.ssh/$group.pub
    set keys=$HOME/.ssh/$group
    if [ -f "$FILE" ]
        ssh-copy-id -i "$FILE" dragon@$lanip;
    else
        ssh-keygen -b 4096 -f $HOME/.ssh/$group q -P "";
        ssh-copy-id -i "$FILE" dragon@$lanip;
    end
    scp -r -i "$keys" "$HOME/scripts/nebula/cert/$group/$hostname" dragon@"$lanip":/home/dragon/;
    echo Dragon6789\^\&\*\( | ssh -tt -i "$keys" dragon@$lanip "cd ~/$hostname && bash ~/$hostname/install.sh"
end

function app-install
    cd ~/momopod/appdata || exit;
    set hostname=$argv[1];
    set apps=$argv[2];
    scp -rC "$apps" "$hostname:/home/dragon/momopod/appdata/";
    ssh "$hostname" "cd ~/momopod/appdata/$apps && bash up.sh"
end

function _cache-tag
    echo Signature: 8a477f597d28d172789f06886806bc55 > $argv[1]/CACHEDIR.TAG
end

function flac-con-all
    set workdir=$PWD;
    for d in $workdir/**/
        cd "$d";
        soundconverter -b ./*.wav -f flac -o ./;
        rm *.wav;
    end
    cd $workdir;
    for d in $workdir/**/**/;
        cd "$d";
        echo "$d";
        soundconverter -b ./*.wav -f flac -o ./;
        rm *.wav;
    end
    cd $workdir
end
function help-me-me
    echo 'ex <file>	: 	Extract file';
    echo '_cache-tag <folder>  : tag cache to folder 4 tar --exclude-caches-all';
    echo 'mp3 <url> : 	youtube-dl mp3';
    echo 'mp3p <playlist url> :	 youtube-dl mp3 playlist';
    echo 'dlv <url> :	youtube-dl video';
    echo 'dlvp <playlist url> :	youtube-dl video playlist';
    echo '_ff   : convert all mp4 files to smaller files size';
    echo 'ufwdel 14 12 11 10 4  :  delete ufw firewall multiple rules big to small number';
    echo 'podmansystemd <container>		: generate podman systemd service file';
    echo 'rimdown <mod-id> :	rimworld download mod';
    echo 'steamdown <app-id> <mod-id> :		download steam workshop';
    echo 'tarscp_from_remote remote_hostend remote_dir_pathend local_dir_pathend';
    echo 'tarscp_to_remote local_dir_pathend remote_hostend remote_dir_pathend';
    echo 'tarscp_from_remote_xz remote_hostend remote_dir_pathend local_dir_pathend';
    echo 'tarscp_to_remote_xz local_dir_pathend remote_hostend remote_dir_pathend';
    echo '_acl <user> <path/to/folder> :	give acl rwx to user for folder';
    echo 'flac-con-all :	on Artist folder to convert all wav to flac';
    echo '
alias | grep <sth>  :		print alias for sth
_history 	:	clear history

nebula_add_host <hostname> <nebulaip> <group> <lanip> ex: nebula_add_host dragon000 172.16.0.100 dragon 192.168.1.45
app-install <hostname> <app>    ex: app-install dragon000 caddy
'
end
