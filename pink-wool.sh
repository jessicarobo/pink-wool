#!/bin/bash
# pink-wool.sh minecraft installer and control panel 1.0.0
# by Jessica Robo~
# MIT License
# vim: set noet ts=4 sw=4 :
#
########## VARIABLES ###########
# Change this if you want a different version of minecraft, but make sure you save it as server.jar
jarfileURL="https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar"
paperURL="https://papermc.io/api/v2/projects/paper/versions/1.16.5/builds/728/downloads/paper-1.16.5-728.jar"
# Other variables and constants -- you probably don't need to change these
ipAddrShow=$(ip addr show | grep global | grep -oe "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | head -n 1 )
megsFree=$(df -BM | grep -e "/$" | awk '{print $4}' | grep -oe '[0-9]*')
ramFree=$(free -m | grep 'Mem:' | awk '{print $2}')
dedotated=$(expr $ramFree - 200)
defaultMotd='A Pink Wool server \\u00A7d^O^'
PWVERSION='1.0.0'
BASEURL='https://raw.githubusercontent.com/jessicarobo/pink-wool'
BRANCH='dev' # CHANGE THIS TO MAIN WHEN YOU COMMIT, YA DOPE   debug r0b0 jjdasda}
CADDYVERSION="2.3.0"
export CADDYVERSION
BADNUMBER="Invalid response. Please enter a number."
HEARTS='\e[1;31m<3 <3 <3\e[0m ~Jessica'
GOK='...\e[1;32mOK!\e[0m'
export GOK
# I really wouldn't change this
INSTALLPATH="/var/opt/minecraft/"
SERVERPROPS="#Minecraft server properties
#(last boot timestamp)
spawn-protection=16
max-tick-time=60000
query.port=25565
force-gamemode=false
allow-nether=true
gamemode=survival
enable-query=false
player-idle-timeout=0
difficulty=easy
spawn-monsters=true
op-permission-level=4
pvp=true
level-type=default
enable-status=true
hardcore=false
enable-command-block=false
max-players=20
max-world-size=29999984
function-permission-level=2
rcon.port=25575
server-port=25565
spawn-npcs=true
allow-flight=false
level-name=world
view-distance=10
spawn-animals=true
white-list=false
rcon.password=
generate-structures=true
online-mode=true
level-seed=
prevent-proxy-connections=false
use-native-transport=true
motd=${defaultMotd}
enable-rcon=false"
########## FUNCTIONS ###########
function testExit() {
	# tests a thing, echoes a thing, exits
	# testExit TEST ECHO_MESSAGE EXIT_CODE
	if eval $1; then
		echo "$2"
		exit $3
	fi
}
function dload() {
	#dload URL OUTPUT
	if [[ -z $dlCommand ]]; then
		which wget &> /dev/null
		if [[ $? -eq 0 ]]; then
			wget -q -O "$2" $1
			return 0
		else
			which curl
			testExit "[[ $? -ne 0 ]]" "wget and curl not found" 102
			# otherwise, I guess curl was found
			curl -s -o "$2" $1
		fi
	fi
}
function debugWait() {
	# debugWait $SECONDS $ID
	echo "Waiting for debug purposes. Param: $2"
	sleep $1
	return 0
}
function numberPrompt() {
	# makes a numbered prompt using read
	# numberPrompt OPTION1 OPTION2 OPTION3 ...
	i=1
	echo ''
	while [[ -n $1 ]]; do
		echo "$i) $1"
		((i++))
		shift 1
	done
}
function trueFalseMenu() {
	# trueFalseMenu VARIABLE_NAME DEFAULT MESSAGE
	unset $1
	trueOpt="true"
	falseOpt="false"
	if [[ $2 == "true" ]]; then
		trueOpt="true (default)"
	fi
	if [[ $2 == "false" ]]; then
		falseOpt="false (default)"
	fi
	while [[ -z ${!1} ]]; do
		numberPrompt "$trueOpt" "$falseOpt"
		readGreen 1 "$3" $1
		case ${!1} in
			1)
				eval $1='true'
			;;
			2)
				eval $1='false'
			;;
			'')
				eval $1="$2"
			;;
			*)
			echo $BADNUMBER
			unset $1
			;;
		esac
	done
}
function editProp() {
	# editProp SERVER_PROPERTY NEW_VALUE
	sed -i "s/^$1=.*$/$1=$2/" server.properties
}
function getInstaller() {
	if [[ ! -r /etc/os-release ]]; then
		echo "Error detecting operating system (does /etc/os-release exist?)"
		exit 100
	fi
	# this file comes with most distros and has a bunch of shell variables
	source /etc/os-release
	# first ubuntu and debian
	case $VERSION_CODENAME in
		"focal" | "ulyssa")
			installName="focal.sh" 
		;;
		"buster")
			installName="buster.sh" 
		;;
		*)
			# i hope this is legal
			case $PRETTY_NAME in
				"CentOS Stream 8")
					installName="centos8.sh"
				;;
				*)
					echo "Unsupported os, for now"
					exit 101
				;;
			esac
		;;
	esac
	dload $BASEURL/$BRANCH/installers/$installName - | bash
	return 0
}
function setPermissions() {
	chown -R minecraft:minecraft ${INSTALLPATH} &> /dev/null
	chown -R www-data:caddy ${INSTALLPATH}www/ &> /dev/null
	chmod 700 ${INSTALLPATH}minecraft-st* &> /dev/null
	chmod -R 770 ${INSTALLPATH}www/admin/backups &> /dev/null
	chmod 660 ${INSTALLPATH}console.* &> /dev/null
	usermod -G caddy -a minecraft &> /dev/null
}
function victory() {
clear
case $1 in
	'' | "install")
		echo -e "\e[1;32mMinecraft is installed and running (pid $(pidof java))! \e[1;35m^O^\e[0m"
		echo -e "Thank you for using \e[1;35mPink Wool\e[0m! The \e[0;34mcontrol panel\e[0m should be available now!"
		echo -e "(try https://${ipAddrShow} or https://${serverHostname})"
		;;
	"minecraft-only")
		echo -e "\e[1;32mMinecraft is installed at ${INSTALLPATH}!\nStart it with java or with \e[0mservice minecraft start. \e[1;35m^O^\e[0m"
	;;
	"uninstall")
		echo -e "Pink Wool and Minecraft have been removed from your system."
	;;
	"update")
		echo -e "Pink Wool has been updated! \e[1;35m^O^\e[0m"
	;;
esac
echo -e "$HEARTS"
exit 0
}
function pwBackup() {
	testExit "[[ ! -d ${INSTALLPATH}www/admin/backups/ ]]" "Backup directory doesn't exist" 104
	/usr/bin/zip -r ${INSTALLPATH}www/admin/backups/minecraft-$(date +%F-%H%M).zip ${INSTALLPATH} -x *.sh -x *.zip
	chown caddy:minecraft ${INSTALLPATH}www/admin/backups/*
	return 0
}
function getPanelFiles() {
	cd ${INSTALLPATH}www
	testExit "[[ $? -ne 0 ]]" "Couldn't change to the panel directory... does it exist??" 102
	if [[ ! -f index.php ]]; then
		dload $BASEURL/$BRANCH/panel/index.php index.php
		testExit "[[ $? -ne 0 ]]" "Couldn't download panel: err $?" 103
	fi
	dload $BASEURL/$BRANCH/panel/pink-wool.css pink-wool.css
	dload $BASEURL/$BRANCH/panel/header.php header.php
	dload $BASEURL/$BRANCH/panel/footer.php footer.php
	dload $BASEURL/$BRANCH/panel/adminindex.php admin/index.php
	dload $BASEURL/$BRANCH/panel/service.php admin/service.php
	dload $BASEURL/$BRANCH/panel/backup.php admin/backup.php
	dload $BASEURL/$BRANCH/pink-wool.sh /usr/sbin/pink-wool
	testExit "[[ $? -ne 0 ]]" "Couldn't download panel: err $?" 103
	chmod 500 /usr/sbin/pink-wool
}
function pwUpdate() {
	testExit "[[ $EUID -ne 0 ]]" "You need to be root (sudo -s)" 91
	remoteVersion="$(dload $BASEURL/$BRANCH/version \-)"
	echo -e "Current: $remoteVersion\nYou have: $PWVERSION"
	if [[ $remoteVersion == $PWVERSION ]]; then
		echo "You're up to date!"
		return 0
	fi
	echo
	while [[ -z $updateOK ]]; do
		numberPrompt "Yes" "No"
		readGreen 1 "Install the remote version?" updateOK
		case $updateOK in 
			1|Y|y)
				getPanelFiles
				victory update
				;;
			*)
				echo "OK, not updating"
				return 0
				;;
		esac
	done
}
function pwHelp() {
	clear
	echo -e "Pink Wool v$PWVERSION is designed to install and uninstall the following:\n"
	echo -e "-Minecraft\n-A set of shell scripts for managing Minecraft\n-A web control panel for the shell scripts\n-Any necessary dependencies (e.g. Java, Caddy, PHP)\n"
	echo -e "Usage: $0 COMMAND\n\nValid commands:\n"
	echo "interactive (or no argument) - interactive mode"
	echo "install - Installs everything"
	echo "minecraft-only - Just installs Minecraft and a systemd service, and doesn't start it"
	echo "help - This screen"
	echo "version - prints version information and quits"
	echo "Once installed:"
	echo "update - Attempts to update Pink Wool (not Minecraft!)"
	echo "uninstall - Attempts to uninstall everything (including Minecraft!)"
	echo "backup - Backs up the server (I recommend stopping it first)"
	echo 'do "minecraft console command" - tries to run an arbitrary command, for example do "op JessicaRobo"'
}
function allProps() {
	editProp gamemode $gameMode
	editProp max-players $playerCount
	editProp level-seed $worldSeed
	editProp white-list $whitelist
	editProp op-permission-level $opLevel
	editProp "enable-command-block" $commandBlock
	editProp pvp $pvp
	editProp difficulty $difficulty
	editProp motd "$serverMotd"
}
function readGreen() {
	# read CHARACTERS PROMPT VARIABLE
	read -e -n $1 -p $'\e[1;32m'"$2"$'\e[0m >' $3
}
function pwUninstall() {
	testExit "[[ $EUID -ne 0 ]]" "You need to be root (sudo -s)" 91
	echo "Really uninstall?? This is going to delete Minecraft and the website"
	sleep 1
	readGreen 1 "Uninstall?" reallyUninstall
		case $reallyUninstall in
			1|y|Y)
				service minecraft stop
				if [[ -z $INSTALLPATH ]]; then
					echo 'hm'
					exit 109
				fi
				rm -rf ${INSTALLPATH}
				rm /etc/cron.d/minecraft-backup
				rm -f /usr/sbin/pink-wool
				testExit "[[ -f /usr/sbin/pink-wool ]]" "Didn't work :o" 110
				deluser minecraft &> /dev/null
				victory uninstall
			;;
			*)
				echo "Doing nothing"
			;;
		esac
	exit 0
}
function installMinecraft() {
	useradd -r -m -U -d ${INSTALLPATH} -s /bin/false minecraft &> /dev/null
	# downloads a per-distro script to get java, caddy, etc
	getInstaller
	cd $INSTALLPATH
	eval $downloadEval
	echo "Running Minecraft once so we can generate a eula.txt & agree to it..."
	/usr/bin/java -jar ${INSTALLPATH}server.jar nogui
	testExit '[[ ! -w "eula.txt" ]]' "Something weird happened... there should be a writeable eula.txt here and there isn't. Maybe that means java didn't run successfully. Sorry, but this error is super fatal! Quitting~" 99
	sed -i 's/^eula=false/eula=true/' eula.txt
	echo -e $GOK
	return 0
}
function pwMenu() {
	unset mainMenuAction
	echo -e "\e[1;35mHiiii! This is Pink Wool, an interactive installer and control panel for Minecraft!\e[0m"
	echo -e "By running this, you \e[0;34magree to the Minecraft eula\e[0m, so make sure you read it!"
	echo -e "\e[1;31mPush CTRL+C at any time to quit!\e[0m\n"
	echo -e "\e[1;35m~Main Menu~\e[0m"
		while [[ -z $mainMenuAction ]]; do
			numberPrompt "Install Minecraft and the control panel" "Just install Minecraft" "Check for updates" "Run a backup" "Execute a command" "Uninstall everything" "Help" "Exit"
			echo ''
			readGreen 1 "Do what?" mainMenuAction
			case $mainMenuAction in
				1)
					pwInstall
				;;
				2)
					pwNoPanel
				;;
				3)
					pwUpdate
				;;
				4)
					pwBackup
				;;
				5)
					readGreen 80 "Enter a command" execArg
					pwExec "$execArg"
				;;
				6) 
					pwUninstall
				;;
				7)
					pwHelp
				;;
				8)
					echo -e "OK! $HEARTS"
					exit 0
				;;
				*)
					echo "$BADNUMBER"
				;;
			esac
			unset mainMenuAction
		done
}
function pwExec() {
	# pwExec "command"
	testExit "[[ ! -p ${INSTALLPATH}console.in ]]" "Pipe not found" 105
	echo "$1" > ${INSTALLPATH}console.in
	return $?
}
function makeFifo() {
	mkfifo ${INSTALLPATH}console.in
	touch ${INSTALLPATH}console.out
}
function pwNoPanel() {
	PWNOPANEL=true
	export PWNOPANEL
	downloadEval="dload $jarfileURL server.jar"
	installMinecraft	
	setFirewall
	makeService
	makeFifo
	setPermissions
	victory minecraft-only
}
function serverProps() {
	# gameMode
	unset gameMode
	while [[ -z $gameMode ]]; do
		numberPrompt "survival (default)" creative adventure spectator
		readGreen 1 "Choose a gamemode" gameModeNum
		case $gameModeNum in
			1 | '')
				gameMode="survival"
			;;
			2)
				gameMode="creative"
			;;
			3)
				gameMode="adventure"
			;;
			4)
				gameMode="spectator"
			;;
			*)
				echo "$BADNUMBER"
			;;
		esac
	done
	# max players
	readGreen 3 'Enter maximum players (default 20)' playerCount
	if [[ $playerCount == '' ]]; then
		playerCount=20
	fi
	while [[ ! $playerCount -gt 0 ]]; do
		echo "Player count has to be a positive number"
		readGreen 3 'Enter maximum players (default 20)' playerCount
	done
	# seed, motd
	readGreen 512 'Enter a seed, if you like' worldSeed
	readGreen 60 "Enter your MOTD (60 characters)" serverMotd
	if [[ $serverMotd == '' ]]; then
		serverMotd="$defaultMotd"
	fi
	# whitelist, command blocks, pvp
	trueFalseMenu whitelist "false" "Enable whitelist? "
	trueFalseMenu commandBlock "false" "Enable command blocks? "
	trueFalseMenu pvp "true" "Enable pvp? "
	# difficulty
	unset difficulty
	while [[ -z $difficulty ]]; do
		numberPrompt "peaceful" "easy (default)" "normal" "hard"
		readGreen 1 'Choose a difficulty:' difficultyNum
		case $difficultyNum in
			1)
				difficulty="peaceful"
			;;
			2 | '')
				difficulty="easy"
			;;
			3)
				difficulty="normal"
			;;
			4)
				difficulty="hard"
			;;
			*)
				echo "$BADNUMBER"
			;;
		esac
	done
	# op level
	unset opLevel
	while [[ -z $opLevel ]]; do
		numberPrompt "bypass spawn protection" "cheats and command blocks" "ban/op" "all commands (default)"
		readGreen 1 "Choose op permission level:" opLevel
		case $opLevel in
			1 | 2 | 3 | 4)
			;;
			'')
				opLevel=4
			;;
			*)
				echo "$BADNUMBER"
				unset opLevel
			;;
		esac
	done
}
function makeService() {
	cat << EOS > /etc/systemd/system/minecraft.service
[Unit]
Description=Minecraft Server
Documentation=

Wants=network.target
After=network.target

[Service]
User=minecraft
Group=minecraft

Restart=always
RestartSec=30
ProtectHome=true
ProtectSystem=full
PrivateDevices=true
NoNewPrivileges=true
PrivateTmp=true
InaccessibleDirectories=/root /sys /srv -/opt /media -/lost+found
ReadWriteDirectories=${INSTALLPATH}
WorkingDirectory=${INSTALLPATH}
ExecStart=${INSTALLPATH}minecraft-start.sh
ExecStop=${INSTALLPATH}minecraft-stop.sh

[Install]
WantedBy=multi-user.target
EOS
	cat << EOA > ${INSTALLPATH}minecraft-start.sh
#!/bin/bash
while true; do cat ${INSTALLPATH}console.in; done | /usr/bin/java -Xms${dedotated}M -Xmx${dedotated}M -XX:+UseG1GC -jar ${INSTALLPATH}server.jar nogui > ${INSTALLPATH}console.out
if [[ ! \$(pidof java) ]]; then
	exit 1
fi
systemd-notify READY=1
exit 0
EOA
	cat << EOB > ${INSTALLPATH}minecraft-stop.sh
#!/bin/bash
echo "say shutting down..." > ${INSTALLPATH}console.in 
sleep 3
echo "save-all" > ${INSTALLPATH}console.in 
sleep 3
echo "stop" > ${INSTALLPATH}console.in 
EOB
	systemctl daemon-reload
}
function makeBackupCron() {
	if [[ $backupMinute -ge 0 ]]; then
		mkdir ${INSTALLPATH}www/admin/backups
		echo "$backupMinute $backupHour * * * minecraft /usr/bin/zip -r ${INSTALLPATH}www/admin/backups/minecraft-$(date +%F-%H-%M).zip ${INSTALLPATH} -x *.sh -x *.zip &> /dev/null" > /etc/cron.d/minecraft-backup
		echo "55 23 * * * minecraft	/usr/bin/find ${INSTALLPATH}www/admin/backups/ -name \*.zip -type f -mtime +7 -delete &> /dev/null" >> /etc/cron.d/minecraft-backup
	fi
	return 0
}
function showVars() {
	unset watchman
	clear
	echo "Hostname: $serverHostname"
	echo "In-game name: $mcUser"
	echo "Admin user: $httpUser"
	echo "Backups: $backupHour:$backupMinute"
	echo "Server type: $downloadJar"
	sleep 2
	cat ${INSTALLPATH}server.properties
	readGreen 1 'Is everything okay? (Y/n)' menuOK
	if [[ $menuOK == "n" || $menuOK == "N" ]]; then
		while [[ -z $armageddon ]]; do
			numberPrompt "Redo server properties menu" "Edit server properties manually" "Quit" "Just kidding! Continue"
			readGreen 1 "What now??" armageddon
			case $armageddon in
				1)
					unset armageddon
					serverProps
					allProps
					watchman=true
					return 0
					;;
				2)
					unset armageddon
					vi ${INSTALLPATH}server.properties
					;;
				3)
					exit 0
					;;
				4)
					unset armageddon
					break
					;;
				*)
					unset armageddon
					echo "$BADNUMBER"
					;;
			esac
		done
	fi
}
function setFirewall() {
	ufw default deny incoming &> /dev/null
	ufw default allow outgoing &> /dev/null
	ufw allow 443 &> /dev/null
	ufw allow ssh &> /dev/null
	ufw allow 25565 &> /dev/null
	service ufw restart &> /dev/null
}
function installPanel() {
	PHPVER=$(php -v | grep -Po '(?<=PHP )([0-9].[0-9])')
	httpPass=$(caddy hash-password --plaintext "$httpPass")
	cat <<EOC > /etc/caddy/Caddyfile
$ipAddrShow, $serverHostname
root * ${INSTALLPATH}www
file_server 
php_fastcgi unix//run/php/php${PHPVER}-fpm.sock
basicauth /admin/* {
	$httpUser $httpPass
}
EOC
	echo '$ a www-data ALL=(ALL) NOPASSWD:/usr/sbin/pink-wool' | EDITOR="sed -f- -i" visudo
	getPanelFiles
	service caddy restart
	cd ${INSTALLPATH}
	return 0
}
function pwInstall() {
	testExit "[[ $EUID -ne 0 ]]" "You need to be root (sudo -s)" 91
	testExit "[[ $megsFree -lt 2000 ]]" "Not really enough hard drive space free. Umm... try getting like 2GB" 92
	testExit "[[ $ramFree -lt 512 ]]" "Download more ram (min: 512MB free, you have $ramFree)" 93
	# hostname
	read -e -p $'\nFirst, \e[1;32menter your domain name\e[0m. For example, \e[0;36mminecraft.yourname.com\e[0m. If you don\'t have one, leave it blank or enter localhost\n>' serverHostname
	if [[ -z $serverHostname ]]; then
		serverHostname='localhost'
	fi
	# minecraft username
	read -e -p $'Enter your \e[1;32mMinecraft username\e[0m (for op)\n>' mcUser
	# https username
	read -e -p $'Choose a \e[1;32mcontrol panel username\e[0m (for example, admin or jessica):\n>' httpUser
	if [[ -z $httpUser ]]; then
		httpUser='admin'
	fi
	# https password
	while [[ -z $httpPass ]]; do
		read -s -p $'Choose a \e[1;32mpassword\e[0m for the web control panel:\n' passGuyOne
		read -s -p $'Type your \e[1;32mpassword\e[0m again to confirm:\n' passGuyTwo
		if [[ $passGuyOne == $passGuyTwo ]]; then
			httpPass=$passGuyOne
		else
			echo "Passwords didn't match."
			sleep 1
		fi
	done
	readGreen 1 "Do you want daily backups? y/N" backupOn
	if [[ $backupOn == "Y" || $backupOn == "y" ]]; then
		timeRegex='([0-9][0-9]:[0-9][0-9])'
		readGreen 5 'When? (00:00-23:59)' backupTime
		if [[ ! $backupTime =~ $timeRegex ]]; then
			backupTime='01:05'
		fi
		backupHour=$(echo $backupTime | cut -d : -f 1)
		backupHour=${backupHour#0}
		if [[ $backupHour -gt 23 ]]; then
			backupHour=23
		fi
		backupMinute=$(echo $backupTime | cut -d : -f 2)
		backupMinute=${backupMinute#0}
		if [[ $backupMinute -gt 59 ]]; then
			backupHour=55
		fi
	fi
	readGreen 1 'Do you want to configure server.properties now? (Y/n)' goConfig
	if [[ $goConfig != "n" && $goConfig != "N" ]]; then
		serverProps
	fi
	# basic setup
	mkdir -p ${INSTALLPATH}www/admin/
	cd $INSTALLPATH
	while [[ -z $downloadJar ]]; do
		numberPrompt "Vanilla" "Paper"
			readGreen 1 "Choose a Minecraft variant" downloadJar
			case $downloadJar in 
				1 | '')
					downloadJar="Vanilla"
					downloadEval="dload $jarfileURL server.jar"
				;;
				2)
					downloadJar="Paper"
					downloadEval="dload $paperURL server.jar"
				;;
				*)
					echo $BADNUMBER
					unset downloadJar
				;;
			esac
	done
	echo -e "$SERVERPROPS" > ${INSTALLPATH}server.properties
	if [[ $goConfig != "n" && $goConfig != "N" ]]; then
		allProps
	fi
	# menu test
	showVars
	while [[ $watchman ]]; do
		showVars
	done
	installMinecraft
	installPanel
	setFirewall
	makeService
	makeFifo
	makeBackupCron
	setPermissions
	service minecraft start
	testExit "[[ $? -gt 0 ]]" "Oh no... system service! Why??" 97
	echo -e "\e[1;35mWaiting for Minecraft to finish world generation...\e[0m"
	i=0
	while [[ -z $worldDone ]]; do
		grep 'Done' ${INSTALLPATH}console.out
		if [[ $? -eq 0 ]]; then
			worldDone=true
			break
		else
			sleep 10
					((i+=10))
					echo "$i seconds..."
		fi
	done
	sleep 2
	echo "op $mcUser" > ${INSTALLPATH}console.in
	testExit "[[ $? -gt 0 ]]" 'Something went wrong right at the end??' 98
	victory
}
########## EXECUTION ###########
clear
case $1 in
	"install")
		pwInstall
		exit 0
	;;
	"uninstall")
		pwUninstall
		exit 0
	;;
	"update")
		pwUpdate
		exit 0
	;;
	"interact" | '')
		pwMenu
	;;
	"minecraft-only")
		pwNoPanel
		exit 0
	;;
	"version")
		echo $PWVERSION
		exit 0
	;;
	"do"|"exec")
		pwExec "$2"
		exit 0
	;;
	# secret options :o
	"start"|"stop"|"status"|"restart")
		service minecraft $1
		exit 0
	;;
	"backup")
		pwBackup
	;;
	*)
		pwHelp
		exit 0
	;;
esac
exit 1
