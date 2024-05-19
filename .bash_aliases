# shellcheck disable=SC2148
# if [ -f ~/.bash_aliases ]; then
#     source ~/.bash_aliases
# fi
alias _workspace='wmctrl -r firefox -t 0;wmctrl -r tilix -t 1;wmctrl -r codium -t 2;wmctrl -r trilium -t 3;wmctrl -r jellyfinmediaplayer -t 5;wmctrl -r virt-manager -t 4; wmctrl -r qemu_system-x86_64 -t 4'
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias _bashrc='micro /home/vugia/.bashrc'
alias _clip='mousepad /home/vugia/clip.txt'
alias _aria2c='aria2c --enable-rpc --rpc-listen-all --rpc-allow-origin-all >/dev/null 2>&1 &'
alias _vmware='sudo modprobe -a vmw_vmci vmmon'
alias _clear='find ~/.cache/ -type f -atime +7 -delete;sudo pamac clean --keep 1;sudo pamac remove -o;sudo pacman -R $(pacman -Qtdq);'
#alias _pulse='systemctl restart --user pulseaudio'
alias _logs='sudo journalctl --since "5 minutes ago"'
alias _history='history -c && echo clear > ~/.bash_history && echo clear > ~/.zhistory'
alias offline='firejail --net=none --noprofile'
alias _gpu='watch -d -n 0.5 nvidia-smi'
alias _ffupdate='/home/vugia/arkenfox-userjs/updater.sh -u -s -b'
alias _yt-local-up='cd /media/WD_Black_1TB/Download/Portable-Programs/youtube-local && git pull'
alias _space='du -h -d 1 . | grep \G | sort -nr | head -40'
alias _space2='du -d 1 . | sort -nr | head -30'
alias disk-space-G='du -h -d 1 . | grep \G | sort -nr | head -30'
alias disk-space-M='du -h -d 1 . | grep \M | sort -nr | head -30'
alias bashrc_reload='source ~/.bashrc'
alias zshrc_reload='source ~/.zshrc'
alias tmuxx='tmux new-session \; split-window -h \; split-window -v \; attach'
alias bluedevices='bluetoothctl -- devices'
alias bluecon='bluetoothctl -- connect'
alias bluedis='bluetoothctl -- disconnect'
alias bluescanon='bluetoothctl -- scan on'
alias bluescanoff='bluetoothctl -- scan off'
alias funcl_con='bluetoothctl -- connect 00:00:00:AA:15:26'
alias funcl_dis='bluetoothctl -- disconnect 00:00:00:AA:15:26'
alias bluehelp='bluetoothctl -- help'
#################################################
###       PACMAN
alias pacinstall='sudo pacman -S'
alias pacin='sudo pacman -S'
alias pacadd='sudo pacman -S'
alias pacrm='sudo pacman -R'
alias pacrms='sudo pacman -Rs'
alias pacremove='sudo pacman -R'
alias pacremoves='sudo pacman -Rs'
alias paclean='sudo pacman -Sc'
alias paclear='sudo pacman -Scc'
alias pacupdate='sudo pacman -Sy'
alias pacupgrade='sudo pacman -Syu'
##################################################
#         ssh aliases
alias _sshmomo='ssh admin@momo.nohost.me -i /home/vugia/.ssh/momonohost'
alias _momodell='ssh momo@192.168.1.82'
alias _vugiadell='ssh vugia@192.168.1.82'
##################################################
###         podman aliases
alias _pod='/home/vugia/podman/_run.sh'
alias docker='podman'
alias pod-com-dry='podman-compose --dry-run up'
alias pod-com-dry-pod='podman-compose --dry-run --in-pod up'
alias pod-com-up='podman-compose down; podman-compose up -d'
alias _compose-up='podman-compose down; podman-compose up -d'
#alias pod-com='podman-compose'
alias polog='podman logs -f --tail 20'
alias popsname="podman ps --format '{{.Names}}'"
alias popsport="podman ps --format '{{.Names}} :  {{.Ports}}"
alias pops='podman ps --format "{{.Names}}   :  {{.Status}}  : {{.State}} : {{.RunningFor}} {{.Command}}"'
alias pod-gen-sys='podman generate systemd --new --container-prefix "" --new --name --no-header --restart-sec 10 --separator "" --files'
alias caddyreload='podman exec caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile'
##################################################
#         aliases games
alias game='bash -i /media/Nvme_Data/Games/game.sh'
alias prot='bash -i /media/Nvme_Data/proton/proton-run.sh'
#alias bottle='flatpak run --unshare=network --command=bottles-cli com.usebottles.bottles --bottle 'Game' --executable'
#alias rim='firejail --net=none --noprofile /media/Nvme_Data/Games/Rimworld-jc141/files/groot/RimWorldLinux'
#alias rim='bash /media/Nvme_Data/Games/Rimworld-jc141/start.n.sh'
alias rim='nohup firejail --net=none --noprofile bottles-cli run -p RimWorld -b 'Game' &>/dev/null &'
alias rimt='sleep 7s && taskset -pac 0,1,2,3,4,5 $(pidof RimWorldWin64.exe) &>/dev/null &'
alias rimtt='rim; rimt'
alias rimm='/media/Nvme_Data/Games/Rimworld-jc141/Rimworld-Mod-download'
#alias rimpy='cd /media/Nvme_Data/Games/Rimworld-jc141/Rimpy/; firejail --net=none --noprofile /media/Nvme_Data/Games/Rimworld-jc141/Rimpy/RimPy.sh'
alias rimp='nohup firejail --net=none --noprofile bottles-cli run -p RimPy -b 'Game' &>/dev/null &'
alias riml='env ENABLE_VKBASALT=1 firejail --net=none --noprofile /media/Nvme_Data/Games/Rimworld-jc141/files/groot/RimWorldLinux'
alias botcli='nohup firejail --net=none --noprofile bottles-cli run -b 'Game' -e '
#alias grim='flatpak run --unshare=network --command=bottles-cli com.usebottles.bottles run -p GrimDawn -b 'Game''
#alias grims='cd /media/Nvme_Data/Games/Grim\ Dawn/GD_stash/ && java -jar GDStash.jar'
#alias grima='/usr/bin/wine start /unix /media/Nvme_Data/Games/Grim\ Dawn/AssetManager.exe' !@#$%^&*(_+-=)
alias LE="nohup firejail --net=none --noprofile bottles-cli run -p 'Last Epoch' -b 'Game' &>/dev/null &"
alias valheim='nohup firejail --net=none --noprofile bottles-cli run -p 'valheim' -b 'Game' &>/dev/null &'
#alias rimt='sleep 7s && taskset -pac 0,1,2,3,4,5 $(pidof RimWorldWin64.exe) &>/dev/null'
##################################################
#### systems and app
alias fox0='firefox -P "Default User"'
alias fox1='firefox -P "arkenfox"'
alias pythonvenv='python3 -m venv venv && source venv/bin/activate'
alias download_gecko='wget https://github.com/mozilla/geckodriver/releases/download/v0.33.0/geckodriver-v0.33.0-linux64.tar.gz; tar -zxf geckodriver-v0.33.0-linux64.tar.gz; chmod +x geckodriver'
alias lla='ls --color=auto -al'
alias wav2flac='soundconverter -b ./*.wav -f flac -o ./ && rm *.wav'
#alias flacall='soundconverter -b -r ./**/ -f flac -o ./ && rm ./**/*.wav && soundconverter -b -r ./**/**/ -f flac -o ./ && rm ./**/**/*.wav'
#alias _service='systemctl --user'
alias _sysuser='systemctl --user'
alias _daemon='systemctl --user daemon-reload'
alias _restart='systemctl --user restart'
alias _start='systemctl --user start'
alias _stop='systemctl --user stop'
alias _ennow='systemctl --user enable --now'
alias _disnow='systemctl --user disable --now'
alias _journal='journalctl --user -xeu'
alias _history='history -c && echo clear > ~/.bash_history'
alias _functl='typeset -F | grep '
alias help-me='help-me-me'

alias egrep='grep -E --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias fgrep='grep -F --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias globurl='noglob urlglobber '
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
# alias history='omz_history -f'
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias ls='ls --color=auto'
alias lsa='ls -lah'
alias md='mkdir -p'
#alias rim='firejail --net=none --noprofile bottles-cli run -p RimWorld -b 'Game' -- %u'
# alias rimpy='firejail --net=none --noprofile bottles-cli run -p RimPy -b 'Game' -- %u'

alias alie='micro ~/.bash_aliases'
alias code='vscodium'

export EDITOR=micro
export PATH=$HOME/.local/bin/:$PATH
export PATH=/home/vugia/scripts/bin/:$PATH
export PATH=$HOME/Applications/:$PATH
# export HISTIGNORE='*6789*'
# export HISTORY_IGNORE="(*6789*|cd|pwd|exit)"
export HISTORY_IGNORE="(*6789*|exit)"
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
export EDITOR=micro
export MC_SKIN=nicedark
export DZR_CBC=g4el58wc0zvf9na1

####################################################################
###             Functions            ###
####################################################################
ex ()
{
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"   ;;
            *.tar.gz)    tar xzf "$1"   ;;
            *.bz2)       bunzip2 "$1"   ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"    ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.Z)         uncompress "$1";;
            *.7z)        7z x "$1"      ;;
            *)           echo "$1 cannot be extracted via ex()" ;;
        esac
    else
    echo "$1 is not a valid file"
    fi
}
if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
        source /etc/profile.d/vte.sh
fi
function ufwdel(){
	# ufwdel 14 12 11 10 2
	for i in $1 $2 $3 $4;do yes|ufw delete "$i";done
}

function podmansystemd() {
	cd ~/.config/systemd/user/ || exit
	podman generate systemd --new --container-prefix "" \
        --name --no-header --restart-sec 10 --separator "" --files
    #podman generate systemd --name --new "$1" > ~/.config/systemd/user/container-"$1".service
	systemctl --user daemon-reload
	podman rm -f "$1"
	systemctl --user enable --now "$1".service
	cd - || exit
}

function rimdown() {
	/media/Nvme_Data/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/steamcmd.sh +force_install_dir /media/Nvme_Data/Games/workshop/ +login anonymous +workshop_download_item 294100 $1 +exit
	echo "workshop_download_item 294100 $1" >> ~/clip.txt
	#ln -sf /media/Nvme_Data/Games/workshop/steamapps/workshop/content/294100/* /media/Nvme_Data/Games/Rimworld-jc141/files/groot/Mods/
	#ln -sf /media/Nvme_Data/Games/workshop/steamapps/workshop/content/294100/* /media/Nvme_Data/Games/RimWorld/Mods/
}

function rimdownnew() {
	#/media/Nvme_Data/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/steamcmd.sh +force_install_dir /media/Nvme_Data/Games/workshop/ +login anonymous +workshop_download_item 294100 $1 +exit
	File=~/clip.txt
    gawk -i inplace '!a[$0]++' ~/clip.txt

	SteamCMD="/media/Nvme_Data/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/steamcmd.sh +force_install_dir /media/Nvme_Data/Games/workshop/ +login anonymous "

	for line in $(cat $File)
	do
		if [ ! -z "$line" ]; then
			id=$(echo "$line" | awk -F'[=]' '{print $2}')
			id=$(echo "$id" | awk -F'&' '{print $1}')
			echo "+workshop_download_item 294100 $id"
			line_cmd="+workshop_download_item 294100 $id"
			#echo "$line_cmd" >> /media/Nvme_Data/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/rimmodnew
			echo "workshop_download_item 294100 $id" >> /media/Nvme_Data/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/rimmod
			SteamCMD+="${line_cmd} "
		fi
	done
	SteamCMD+="+quit"
	#echo "$SteamCMD"
	eval "$SteamCMD"
	echo "" > $File
	/usr/bin/rm -rf ~/Steam/logs/*
	# gawk -i inplace '!a[$0]++' /media/Nvme_Data/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/rimmodnew
}

function steamdown(){
	/media/Nvme_Data/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/steamcmd.sh +force_install_dir /media/Nvme_Data/Games/workshop/ +login anonymous +workshop_download_item $1 $2 +exit
}

function rimupdate-shutdown() {
	gawk -i inplace '!a[$0]++' /media/Nvme_Data/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/rimmod
	cd /media/Nvme_Data/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd || exit
    /media/Nvme_Data/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/steamcmd.sh +runscript rimmod +quit
    #cd /media/Nvme_Data/Games/Rimworld-jc141/
    #parallel -j 5 git clone {} < rimmods
    #ln -sf /media/Nvme_Data/Games/workshop/steamapps/workshop/content/294100/* /media/Nvme_Data/Games/Rimworld-jc141/files/groot/Mods/
    #ln -sf /media/Nvme_Data/Games/workshop/steamapps/workshop/content/294100/* /media/Nvme_Data/Games/RimWorld/Mods/
    /bin/rm -rf /home/vugia/Steam/logs/*
    xfce4-session-logout --halt --fast
}


function tarscp_from_remote() {
    if [ "$#" -ne 3 ]; then echo "Usage: tarscp_from_remote {remote_host} {remote_dir_path} {local_dir_path}" >&2; return; fi
    ssh "$1" "tar -C $2 -cf - ./" | tar -C "$3" -xf -
}
function tarscp_to_remote() {
    if [ "$#" -ne 3 ]; then echo "Usage: tarscp_to_remote {local_dir_path} {remote_host} {remote_dir_path}" >&2; return; fi
    tar -C "$1" -cf - ./ | ssh "$2" "tar -C $3 -xf -"
}
		#And the version with compression (xz):
function tarscp_from_remote_xz() {
    if [ "$#" -ne 3 ]; then echo "Usage: tarscp_from_remote_xz {remote_host} {remote_dir_path} {local_dir_path}" >&2; return; fi
    ssh "$1" "tar -C $2 -Jcf - ./" | tar -C "$3" -Jxf -
}
function tarscp_to_remote_xz() {
    if [ "$#" -ne 3 ]; then echo "Usage: tarscp_to_remote_xz {local_dir_path} {remote_host} {remote_dir_path}" >&2; return; fi
    tar -C "$1" -Jcf - ./ | ssh "$2" "tar -C $3 -Jxf -"
}

#########################################
#			setfacl
function _acl() {
	if [ "$#" -ne 2 ]; then echo "Usage: _acl <user> <folder>" >&2; return; fi
	local user=$1
	local folder=$2
	sudo setfacl -Rm u:"$user":rwx "$folder"
	sudo setfacl -Rm d:u:"$user":rwx "$folder"
}
##########################################
###search and replace all text in folder
function search-replace-all () {
	if [ "$#" -ne 2 ]; then echo "Usage: search-replace-all <search text> <replacetext>" >&2; return; fi
	grep -RiIl "$1" | xargs sed -i "s|$1|$2|g"
}


#########################################
#			nebula

function _cache-tag() {
	echo Signature: 8a477f597d28d172789f06886806bc55 >$1/CACHEDIR.TAG
}
function flac-con-all(){
	# find . -name "*.wav" -exec soundconverter -b -f flac {} \;  
    workdir=$PWD
    for d in $workdir/**/
    do
        cd "$d" || exit
        #echo "$d"; ls
        soundconverter -b ./*.wav -f flac -o ./
        rm *.wav
    done
    cd $workdir || exit

    for d in $workdir/**/**/
    do
        cd "$d" || exit; echo "$d"
        #echo "$d"; ls
        soundconverter -b ./*.wav -f flac -o ./
        rm *.wav
    done
    cd $workdir || exit
}


function agh-cp-conf () {
	ssh n9-qemu killall AdGuardHome
	scp momo-dell6430:/home/momo/momopod/app/adguardhome/conf/AdGuardHome.yaml n9-qemu:/root/AdguardHome
	# scp ~/podman/AdGuardHome.yaml n9-qemu:/root/AdguardHome
	ssh n9-qemu rc-service AdGuardHome start
}


function help-me-me() {
	echo 'ex <file>	: 	Extract file'
	echo '_cache-tag <folder>  : tag cache to folder 4 tar --exclude-caches-all'
	echo 'mp3 <url> : 	youtube-dl mp3'
	echo 'mp3p <playlist url> :	 youtube-dl mp3 playlist'
	echo 'dlv <url> :	youtube-dl video'
	echo 'dlvp <playlist url> :	youtube-dl video playlist'
	echo '_ff   : convert all mp4 files to smaller files size'
	echo 'ufwdel 14 12 11 10 4  :  delete ufw firewall multiple rules big to small number'
	echo 'podmansystemd <container>		: generate podman systemd service file'
	echo 'rimdown <mod-id> :	rimworld download mod
rimdownnew: download all new mods from clip.txx
rimupdate-shutdown:  update mods and shutdown'
	echo 'steamdown <app-id> <mod-id> :		download steam workshop'
	echo 'tarscp_from_remote {remote_host} {remote_dir_path} {local_dir_path}'
	echo 'tarscp_to_remote {local_dir_path} {remote_host} {remote_dir_path}'
	echo 'tarscp_from_remote_xz {remote_host} {remote_dir_path} {local_dir_path}'
	echo 'tarscp_to_remote_xz {local_dir_path} {remote_host} {remote_dir_path}'
	echo '_acl <user> <path/to/folder> :	give acl rwx to user for folder'
	echo 'flac-con-all :	on Artist folder to convert all wav to flac'
	echo '
alias | grep <sth>  :		print alias for sth
_history 	:	clear history

nebula_add_host <hostname> <nebulaip> <group> <lanip> ex: nebula_add_host dragon000 172.16.0.100 dragon 192.168.1.45
app-install <hostname> <app>    ex: app-install dragon000 caddy

search-replace-all <search text> <replacetext>

_workspace: workspace set
'
}
alias screenoff='xset -display :0.0 dpms force off; read ans; xset -display :0.0 dpms force on'
export "MICRO_TRUECOLOR=1"