# shellcheck disable=SC2148
# if [ -f ~/.bash_aliases ]; then
#     source ~/.bash_aliases
# fi
alias alig='alias | grep'
alias helpme='help-me-me | grep'
alias gpt='tgpt --provider pollinations'
#alias help-me='help-me-me'

alias _xfix='xfdesktop -Q && xfdesktop -e > /tmp/xf.log 2>&1 & ; xfwm4 --replace'
alias _workspace='wmctrl -r firefox -t 0;wmctrl -r xfce4-terminal -t 2;wmctrl -r tilix -t 2;wmctrl -r codium -t 1;wmctrl -r trilium -t 3;wmctrl -r jellyfinmediaplayer -t 5;wmctrl -r virt-manager -t 4; wmctrl -r qemu_system-x86_64 -t 4'
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias _bashrc='micro /home/vugia/.bashrc'
alias _clip='mousepad /home/vugia/clip.txt'
alias _aria2c='aria2c --enable-rpc --rpc-listen-all --rpc-allow-origin-all >/dev/null 2>&1 &'
alias _vmware='sudo modprobe -a vmw_vmci vmmon'
alias _clear='find ~/.cache/ -type f -atime +7 -delete;sudo pamac clean --keep 1;sudo pamac remove -o;sudo pacman -R $(pacman -Qtdq);'
alias _pac-cache='sudo paccache -rk1; sudo paccache -ruk0'
#alias _pulse='systemctl restart --user pulseaudio'
alias _logs='sudo journalctl --since "5 minutes ago"'
alias _history='history -c && echo clear > ~/.bash_history && echo clear > ~/.zhistory'
alias offline='firejail --net=none --noprofile'
alias _gpu='watch -d -n 0.5 nvidia-smi'
alias _ffupdate='/home/vugia/arkenfox-userjs/updater.sh -u -s -b'
alias _yt-local-up='cd /media/WD_Black_1TB/Download/Portable-Programs/youtube-local && git pull'
alias zshup='git -C /home/vugia/.oh-my-zsh/custom/plugins/zsh-autosuggestions pull;git -C /home/vugia/.oh-my-zsh/custom/plugins/zsh-completions pull;git -C /home/vugia/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting pull'
#alias dotpull='git -C ~/dotfiles reset --hard;git -C ~/dotfiles pull'
# alias dotfetch='git -C ~/dotfiles fetch; git -C ~/dotfiles reset --hard origin/main'
alias dotfetch='git -C ~/dotfiles stash; git -C ~/dotfiles pull origin main; git -C ~/dotfiles stash apply'
# alias _space='du -h -d 1 . | grep \G | sort -nr | head -40'
# alias _space2='du -d 1 . | sort -nr | head -30'
alias bluedevices='bluetoothctl -- devices'
alias bluecon='bluetoothctl -- connect'
alias bluedis='bluetoothctl -- disconnect'
alias bluescanon='bluetoothctl -- scan on'
alias bluescanoff='bluetoothctl -- scan off'
alias funcl_con='bluetoothctl -- connect 00:00:00:AA:15:26'
alias funcl_dis='bluetoothctl -- disconnect 00:00:00:AA:15:26'
alias bluehelp='bluetoothctl -- help'

alias phone-remote='scrcpy --video-codec=h265 --max-size=2000 --max-fps=75 --turn-screen-off --power-off-on-close --no-audio -K &>/dev/null &'
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
alias yarm='yay -Rns'
##################################################
#           ssh aliases                          #

##################################################
###         podman aliases
alias _pod='/home/vugia/podman/_run.sh'
alias docker='podman'
alias pocomdry='podman-compose --dry-run --verbose up'
alias pocomdrypod='podman-compose --dry-run --verbose --in-pod up'
alias pocomup='podman-compose down; podman-compose up -d'
alias pcup='podman-compose down; podman-compose up -d'
alias pocom='podman-compose'
alias pc='podman-compose'
alias podlet='podman run ghcr.io/containers/podlet'
alias pcup='podman compose up -d --force-recreate'
alias pcpull='podman-compose pull && podman-compose down && podman-compose up -d'

function pocomupdate () {
	find ~/podman/app -mindepth 2 -maxdepth 2 -type f -iname compose -exec sh -c 'podman-compose -f "$1" pull; podman-compose -f "$1" down; podman-compose -f "$1" up -d' - {}  \;
	}
alias polog='podman logs -f --tail 30'
alias popsname="podman ps --format '{{.Names}}'"
alias popsport="podman ps --format '{{.Names}} :  {{.Ports}}'"
alias pops='podman ps --format "{{.Names}}   :  {{.Status}}  : {{.State}} : {{.RunningFor}} {{.Command}}"'
alias pogensys='podman generate systemd --new --container-prefix "" --new --name --no-header --restart-sec 10 --separator "" --files'
alias caddyreload='podman exec caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile'
alias popo='podman port'
alias popu='podman pull'
alias por='podman run'
alias pord='podman run -d'
alias pordt='podman run -dt'
alias porit='podman run --interactive --tty'
alias porm='podman rm'
alias pormf='podman rm --force'
alias pore='podman restart'
alias posta='podman start'
alias postalways='podman --log-level=info start --all --filter restart-policy=always --filter restart-policy=unless-stopped'
alias postall='podman start $(podman ps -qa)'
alias posto='podman stop'
alias postoa='podman stop $(podman ps --quiet)'
alias potop='podman top'
alias povoli='podman volume inspect'
alias povols='podman volume ls'
alias povolprune='podman volume prune'
alias pox='podman exec'
alias poxit='podman exec --interactive --tty'
alias posear='podman search'
alias posec='podman secret'
alias postat='podman stats'
alias authelia=' podman run --rm -v ~/podman/app/authelia/config:/config -v ~/podman/app/authelia/secrets:/secrets docker.io/authelia/authelia authelia'
alias autheliad=' podman run --rm -v ~/momopod/app/authelia/config:/config -v ~/momopod/app/authelia/secrets:/secrets docker.io/authelia/authelia authelia'
##################################################
#         aliases games
alias game='bash -i ~/GAMES/proton/game.sh'
alias prot='bash -i ~/GAMES/proton/proton-run.sh'
#alias bottle='flatpak run --unshare=network --command=bottles-cli com.usebottles.bottles --bottle 'Game2' --executable'
#alias rim='firejail --net=none --noprofile $HOME/GAMES/Games/Rimworld-jc141/files/groot/RimWorldLinux'
#alias rim='bash $HOME/GAMES/Games/Rimworld-jc141/start.n.sh'
alias rim="nohup firejail --net=none --noprofile bottles-cli run -p RimWorld -b 'Game2' &>/dev/null &"
alias rimt='sleep 15s && taskset -pac 0,1,2,3,4,5 $(pidof RimWorldWin64.exe) &>/dev/null &'
alias rimtt='rim; rimt'
alias rimm='~/GAMES/Games/Rimworld-jc141/Rimworld-Mod-download'
#alias rimpy='cd $HOME/GAMES/Games/Rimworld-jc141/Rimpy/; firejail --net=none --noprofile $HOME/GAMES/Games/Rimworld-jc141/Rimpy/RimPy.sh'
alias rimp="nohup firejail --net=none --noprofile bottles-cli run -p RimPy -b 'Game2' &>/dev/null &"
alias riml='/bin/rm -rf ~/.cache/nvidia/*; gamemoderun /home/vugia/Downloads/Rimworld-jc141/files/game-root/start_RimWorld.sh &>/dev/null &'
alias rimlt='riml; sleep 15; taskset -pac 0,1,2,3,4 $(pidof RimWorldLinux) &>/dev/null &'
alias botcli="nohup firejail --net=none --noprofile bottles-cli run -b 'Game2' -e "
#alias grim='flatpak run --unshare=network --command=bottles-cli com.usebottles.bottles run -p GrimDawn -b 'Game2''
#alias grims='cd $HOME/GAMES/Games/Grim\ Dawn/GD_stash/ && java -jar GDStash.jar'
#alias grima='/usr/bin/wine start /unix $HOME/GAMES/Games/Grim\ Dawn/AssetManager.exe' !@#$%^&*(_+-=)
alias LE="nohup firejail --net=none --noprofile bottles-cli run -p 'Last Epoch' -b 'Game2' &>/dev/null &"
alias valheim="nohup firejail --net=none --noprofile bottles-cli run -p 'valheim' -b 'Game2' &>/dev/null &"
#alias rimt='sleep 7s && taskset -pac 0,1,2,3,4,5 $(pidof RimWorldWin64.exe) &>/dev/null'
##################################################
#### systems and app
export RMM_PATH="$HOME/Downloads/Rimworld-jc141/files/game-root/Mods"
alias fox0='firefox -P "Default User"'
alias fox1='firefox -P "arkenfox"'
alias pythonvenv='python3 -m venv venv && source venv/bin/activate'
alias download_gecko='wget https://github.com/mozilla/geckodriver/releases/download/v0.33.0/geckodriver-v0.33.0-linux64.tar.gz; tar -zxf geckodriver-v0.33.0-linux64.tar.gz; chmod +x geckodriver'

alias wav2flac='soundconverter -b ./*.wav -f flac -o ./ && rm *.wav'
#alias flacall='soundconverter -b -r ./**/ -f flac -o ./ && rm ./**/*.wav && soundconverter -b -r ./**/**/ -f flac -o ./ && rm ./**/**/*.wav'
#alias _service='systemctl --user'
alias sys-user='systemctl --user'
alias service='systemctl --user'
alias _daemon='systemctl --user daemon-reload'
alias _restart='systemctl --user restart'
alias restartd='systemctl --user restart'
alias _start='systemctl --user start'
alias startd='systemctl --user start'
alias _stop='systemctl --user stop'
alias stopd='systemctl --user stop'
alias _status='systemctl --user status'
alias _ennow='systemctl --user enable --now'
alias _disnow='systemctl --user disable --now'
alias _journal='journalctl --user -xeu'
alias _history='history -c && echo clear > ~/.bash_history'
#alias _functl='typeset -F | grep '

alias egrep='grep -E --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias fgrep='grep -F --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias globurl='noglob urlglobber '
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
# alias history='omz_history -f'
alias l='lsd -lah'
alias la='lsd -lAh'
alias ll='lsd -lh'
alias ls='lsd --color=auto'
alias lsa='lsd -lah'
alias lla='lsd --color=auto -al'
alias md='mkdir -p'
alias c='clear'
# alias d='zoxide'
#alias rim='firejail --net=none --noprofile bottles-cli run -p RimWorld -b 'Game' -- %u'
# alias rimpy='firejail --net=none --noprofile bottles-cli run -p RimPy -b 'Game' -- %u'
alias alie='vscodium ~/.zshrc ~/.bash_aliases'
alias code='vscodium'
alias codi='$HOME/.vscodium-server/bin/2ae20ed17e7533b35fc012f4ad1a156fd763afb2/bin/remote-cli/codium'
#alias bashrc_reload='source ~/.bashrc'
alias zshrc_reload='source ~/.zshrc'
alias tmuxx='tmux new-session \; split-window -h \; split-window -v \; attach'

export EDITOR=micro
export PATH=$HOME/.local/bin:$PATH
export PATH=/home/vugia/scripts/bin:$PATH
export PATH=$HOME/Applications:$PATH
export PATH=$HOME/.local/share/RimSort/instances/Default/steamcmd:$PATH
# export HISTIGNORE='*6789*'
# export HISTORY_IGNORE="(*6789*|cd|pwd|exit)"
export HISTORY_IGNORE="(*6789*|exit|hash)"
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
export EDITOR=micro
export MC_SKIN=nicedark

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
function ufwdel(){
	# ufwdel 14 12 11 10 2
	for i in $1 $2 $3 $4;do yes| sudo ufw delete "$i";done
}

ufw_allow_port_ip() {
	local PORT="$1"
	local IP_ADDRESS="$2"

	if [ -z "$PORT" ] || [ -z "$IP_ADDRESS" ]; then
		echo "Usage: ufw_allow_port_ip <PORT> <IP_ADDRESS>"
		return 1
	fi

	sudo ufw allow from "$IP_ADDRESS" to any port "$PORT" proto tcp
	sudo ufw allow from "$IP_ADDRESS" to any port "$PORT" proto udp

	echo "Rules added for port $PORT from IP $IP_ADDRESS for TCP/UDP."
}

mp3 () {
    yt-dlp --ignore-errors -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 -o '%(title)s.%(ext)s' "$1"
}

mp3p () {
    yt-dlp --ignore-errors --sleep-interval 30 -i -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 -o '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' "$1"
}

dlv () {
    yt-dlp --concurrent-fragments 16 -P temp:./temp --downloader aria2c --ignore-errors -o '%(title)s.%(ext)s' "$1"
}

dlp () {
    yt-dlp -P temp:./temp --downloader aria2c --yes-playlist --ignore-errors --sleep-interval 30 -o '%(playlist)s/%(title)s.%(ext)s' "$1"
}

function podmansystemd() {
	cd ~/.config/systemd/user/ || exit
	podman generate systemd --new --container-prefix "" \
        --name --no-header --restart-sec 5 --separator "" --files "$1"
    #podman generate systemd --name --new "$1" > ~/.config/systemd/user/container-"$1".service
	systemctl --user daemon-reload
	podman rm -f "$1"
	systemctl --user enable --now "$1".service
	cd - || exit
}

function rimdown() {
	$HOME/GAMES/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/steamcmd.sh +force_install_dir "/home/vugia/.local/share/RimSort/instances/Default/steam" +login anonymous +workshop_download_item 294100 $1 +exit
	echo "workshop_download_item 294100 $1 validate" >> ~/clip.txt
	#ln -sf $HOME/GAMES/Games/workshop/steamapps/workshop/content/294100/* $HOME/GAMES/Games/Rimworld-jc141/files/groot/Mods/
	#ln -sf $HOME/GAMES/Games/workshop/steamapps/workshop/content/294100/* $HOME/GAMES/Games/RimWorld/Mods/
}

function modtitle () {
	wget -qO- "https://steamcommunity.com/sharedfiles/filedetails/?id=$1" | gawk -v IGNORECASE=1 -v RS='</title' 'RT{gsub(/.*<title[^>]*>/,"");print;exit}' | sed -e 's|Steam Workshop::|\\\\ |g'
}

function rimdownnew() {
	#$HOME/GAMES/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/steamcmd.sh +force_install_dir $HOME/GAMES/Games/workshop/ +login anonymous +workshop_download_item 294100 $1 +exit
	File=~/clip.txt
    gawk -i inplace '!a[$0]++' ~/clip.txt

	SteamCMD="$HOME/GAMES/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/steamcmd.sh +force_install_dir $HOME/GAMES/Games/workshop/ +login anonymous "

	for line in $(cat $File)
	do
		if [ ! -z "$line" ]; then
			id=$(echo "$line" | awk -F'[=]' '{print $2}')
			id=$(echo "$id" | awk -F'&' '{print $1}')
			echo "+workshop_download_item 294100 $id validate $(modtitle "$id")"
			line_cmd="+workshop_download_item 294100 $id validate"
			#echo "$line_cmd" >> $HOME/GAMES/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/rimmodnew
			echo "workshop_download_item 294100 $id validate $(modtitle "$id")" >> $HOME/GAMES/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/rimmod
			SteamCMD+="${line_cmd} "
		fi
	done
	SteamCMD+="+quit"
	#echo "$SteamCMD"
	eval "$SteamCMD"
	#echo "" > $File
	/usr/bin/rm -rf ~/Steam/logs/*
	# gawk -i inplace '!a[$0]++' $HOME/GAMES/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/rimmodnew
}

function steamdown(){
	$HOME/GAMES/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/steamcmd.sh +force_install_dir $HOME/GAMES/Games/workshop/ +login anonymous +workshop_download_item $1 $2 +exit
}

function rimupdate-shutdown() {
	gawk -i inplace '!a[$0]++' $HOME/GAMES/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/rimmod
	cd $HOME/GAMES/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd || exit
    $HOME/GAMES/Games/Rimworld-jc141/SteamModDownloader/scripts/steamcmd/steamcmd.sh +runscript rimmod +quit
    #cd $HOME/GAMES/Games/Rimworld-jc141/
    #parallel -j 5 git clone {} < rimmods
    #ln -sf $HOME/GAMES/Games/workshop/steamapps/workshop/content/294100/* $HOME/GAMES/Games/Rimworld-jc141/files/groot/Mods/
    #ln -sf $HOME/GAMES/Games/workshop/steamapps/workshop/content/294100/* $HOME/GAMES/Games/RimWorld/Mods/
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

tar_backup(){
    FILENAME=$1-$(date '+%Y-%m-%d')
    echo creating backup $FILENAME.tar.zst.gpg
    tar -I 'zstd -T2 -7' -cf - --exclude-caches --exclude-backups \
        --exclude='*cache*' --exclude='*Cache*' --exclude='*tmp*' $1 | gpg -o- -c --batch \
        --passphrase "MoMo6789\!@#" | split -d -b 2000m - $FILENAME.tar.zst.gpg.
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
function dotfile () {
	cd ~/dotfiles || exit
	git add --all
	git commit -a -m "$(date '+%Y-%m-%d %H:%M')"
	git push
}

function rustdeskd () {
	cd $HOME || exit
	if [ ! -f  $HOME/rustdesk.AppImage ]; then
		LATEST_RELEASE_URL=https://github.com/rustdesk/rustdesk/releases/latest
		release_url=$(curl -Ls -o /dev/null -w "%{url_effective}" $LATEST_RELEASE_URL)
		version=${release_url##*/}
		download_url=https://github.com/rustdesk/rustdesk/releases/download/$version/rustdesk-$version-x86_64.AppImage
		download_file=./rustdesk.AppImage
		echo "Downloading $download_url"
		wget -q --show-progress $download_url -O $download_file
		chmod +x rustdesk.AppImage
		nohup ./rustdesk.AppImage &>/dev/null &
	else
		nohup ./rustdesk.AppImage &>/dev/null &
	fi
}

function rustdeskup () {
	cd "$HOME" || exit
	LATEST_RELEASE_URL=https://github.com/rustdesk/rustdesk/releases/latest
	release_url=$(curl -Ls -o /dev/null -w "%{url_effective}" $LATEST_RELEASE_URL)
	version=${release_url##*/}
	download_url=https://github.com/rustdesk/rustdesk/releases/download/$version/rustdesk-$version-x86_64.AppImage
	download_file=./rustdesk.AppImage
	echo "Downloading $download_url"
	wget -q --show-progress $download_url -O $download_file
	chmod +x rustdesk.AppImage
	nohup ./rustdesk.AppImage &>/dev/null &
}

function caddyproxy () {
	if [ "$#" -ne 2 ]; then echo "Usage: caddyproxy <app> <localhost:port>" >&2; return; fi
	local APP=$1
	local ADDRESS=$2

	if [ ! -f " $HOME/momopod/app/caddy/etc-caddy/$APP.caddyfile" ]; then
		echo "$APP.momoin.duckdns.org {
	encode zstd
	import headers
	#import secure
	reverse_proxy $ADDRESS
}

$APP.momoin.duckdns.org:80 {
	redir $APP.momoin.duckdns.org:443
}
" >> $HOME/momopod/app/caddy/etc-caddy/$APP.caddyfile
	fi
}

function authereg () {
	if [ "$#" -ne 4 ]; then echo "Usage: authereg <user> '<password>' <display name> <email>" >&2; return; fi
	# DIGEST=$(printf "%s" "$2" | podman run --rm docker.io/authelia/authelia authelia crypto hash generate argon2 --password - | sed -e 's|Digest: ||g')
	DIGEST=$(podman run --rm docker.io/authelia/authelia authelia crypto hash generate argon2 --password "$2" | sed -e 's|Digest: ||g')
	echo "  $1:\n    displayname: $3\n    password: $DIGEST\n    email: $4\n    groups:\n      - users\n    disabled: false\n" >> /home/momo/momopod/app/authelia/config/users_database.yml
}

##########################################################################
#        END HERE DO NOT WRITE FUNCTIONS ALIAS BELOW
function help-me-me() {
	echo ' HELP MYSELF FUNCTION
ex <file>       :       Extract file
_cache-tag <folder>  : tag cache to folder 4 tar --exclude-caches-all
mp3 <url> :     yt-dlpp mp3
mp3p <playlist url> :    yt-dlpp mp3 playlist
dlv <url> :     yt-dlpp video
dlvp <playlist url> :   yt-dlpp video playlist
_ff   : convert all mp4 files to smaller files size
ufwdel 14 12 11 10 4  :  delete ufw firewall multiple rules big to small number
ufw_allow_port_ip <PORT> <IP_ADDRESS>
podmansystemd <container>               : generate podman systemd service file
rimdown <mod-id> :      rimworld download mod
rimdownnew: download all new mods from clip.txx
rimupdate-shutdown:  update mods and shutdown
steamdown <app-id> <mod-id> :           download steam workshop
tar_backup {Folder}
tarscp_from_remote {remote_host} {remote_dir_path} {local_dir_path}
tarscp_to_remote {local_dir_path} {remote_host} {remote_dir_path}
tarscp_from_remote_xz {remote_host} {remote_dir_path} {local_dir_path}
tarscp_to_remote_xz {local_dir_path} {remote_host} {remote_dir_path}
_acl <user> <path/to/folder> :  give acl rwx to user for folder
flac-con-all :  n Artist folder to convert all wav to flac
alias | grep <sth>  : print alias for sth
_history        :       clear history
nebula_add_host <hostname> <nebulaip> <group> <lanip> ex: nebula_add_host dragon000 172.16.0.100 dragon 192.168.1.45
app-install <hostname> <app>    ex: app-install dragon000 caddy
rustdeskup : download lastest and run rustdesk appimage
search-replace-all <search text> <replacetext>
_workspace: workspace set
dotfile : push dotfiles to github
dotfetch: update dotfiles on clone repo
ohshbaseinstall : install zsh base plugin themes
caddyproxy <App-name> <localhost:port>  ex: caddyproxy baby 127.0.0.1:1900
export LLDAP_HTTPURL='https://lldap.momoruru.duckdns.org'
eval $(lldap-cli -D admin -w 'yourlldapaminpassword' login)

### lldap Add user
lldap-cli user add jsmith john.smith@example.com -d "John Smith" -p hunterpassword
### lldap Change password
lldap-cli user update set john.smith@example.com password hunter2password
### lldap  Group create
lldap-cli group add "jellyfin-users"
### lldap Add to group
lldap-cli user group add jsmith "jellyfin-users"
'
}

alias screenoff='xset -display :0.0 dpms force off; read ans; xset -display :0.0 dpms force on'
export "MICRO_TRUECOLOR=1"
