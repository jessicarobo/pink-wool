#!/bin/bash
# pink-wool.sh minecraft installer and control panel v0.3
# by Jessica Robo~
#
########## VARIABLES ###########
# Comment or remove this next line for other OSes (untested but I might add them later)
aptCheck="true"
# Change this if you want a different version of minecraft, but make sure you save it as server.jar
jarfileURL="https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar"
paperURL="https://papermc.io/api/v2/projects/paper/versions/1.16.5/builds/728/downloads/paper-1.16.5-728.jar"
caddyVersion="2.3.0"
mcrconVersion="0.7.1"
# Other variables and constants -- you probably don't need to change these
rconPass=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c6)
ipAddrShow=$(ip addr show | grep global | grep -oe "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | head -n 1 )
megsFree=$(df -BM | grep -e "/$" | awk '{print $4}' | grep -oe '[0-9]*')
ramFree=$(free -m | grep 'Mem:' | awk '{print $2}')
dedotated=$(expr $ramFree - 200)
defaultMotd="A Pink Wool server \u00A7d^O^"
BADNUMBER="Invalid response. Please enter a number."
DEPENDENCIES="openjdk-16-jre-headless ufw zip php-cli php-fpm"
HTMLHEAD='<!DOCTYPE html>
<html>
<head>
	<meta name="viewport" content="width=device-width">
	<link rel="stylesheet" href="/pink-wool.css">'
HTMLEND='<hr>
<footer>
  <ul>
	<li><a href="/index.php">Index</a></li>
	<li><a href="/admin/index.php">Panel</a></li>
	<li><a href="https://github.com/jessicarobo/pink-wool">Github</a></li>
  </ul>
</footer>
</body>
</html>'
########## FUNCTIONS ###########
function testExit() {
	# tests a thing, echoes a thing, exits
	# testExit TEST ECHO_MESSAGE EXIT_CODE
	if eval $1; then
		echo $2
		exit $3
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
#
#
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
##### REVISE THIS TO MAKE WHOLE PAGES
function newPHP () {
	# make <html> and <head> for a new php file
	# newPHP PATH_TO_OUTPUT HTML_TITLE H1_TITLE
	cat <<EOHEAD > $1
$HTMLHEAD
	<title>$2</title>
</head>
<body>
	<h1>$3</h1>
	<hr>
EOHEAD
}
function victory() {
	clear
	echo -e "\e[1;32mMinecraft is installed and running (pid $(pidof java))! \e[1;35m^O^\e[0m"
	echo -e "Thank you for using \e[1;35mPink Wool\e[0m! If you installed the \e[0;34mcontrol panel\e[0m, it should be available now!"
	echo -e "(try https://${ipAddrShow} or https://${serverHostname})"
	echo -e "\e[1;31m<3 <3 <3\e[0m ~Jessica"
	exit 0
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
KillMode=none
SuccessExitStatus=0 1

Restart=always
RestartSec=30
ProtectHome=true
ProtectSystem=full
PrivateDevices=true
NoNewPrivileges=true
PrivateTmp=true
InaccessibleDirectories=/root /sys /srv -/opt /media -/lost+found
ReadWriteDirectories=/var/opt/minecraft/
WorkingDirectory=/var/opt/minecraft/
ExecStart=/var/opt/minecraft/minecraft-start.sh
ExecStop=/var/opt/minecraft/minecraft-stop.sh

[Install]
WantedBy=multi-user.target
EOS
	cat << EOA > /var/opt/minecraft/minecraft-start.sh
#!/bin/bash
/usr/bin/java -Xms${dedotated}M -Xmx${dedotated}M -XX:+UseG1GC -jar /var/opt/minecraft/server.jar nogui
EOA
	cat << EOB > /var/opt/minecraft/minecraft-stop.sh
#!/bin/bash
/usr/bin/mcrcon -p $rconPass -w 3 'say shutting down...' save-all stop
EOB
	chmod 700 /var/opt/minecraft/minecraft-st*
	systemctl daemon-reload
	chown -R minecraft:minecraft /var/opt/minecraft
}
function backupCron() {
	if [[ $backupMinute -ge 0 ]]; then
		mkdir /var/opt/minecraft/www/admin/backups
		echo "$backupMinute $backupHour * * * minecraft /usr/bin/zip -r /var/opt/minecraft/www/admin/backups/minecraft-\$(date +%F).zip /var/opt/minecraft/world/" > /etc/cron.d/minecraft-backup
		echo '55 23 * * * minecraft	/usr/bin/find /var/opt/minecraft/www/admin/backups/ -name "*.zip" -type f -mtime +7 -delete' >> /etc/cron.d/minecraft-backup
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
	cat /var/opt/minecraft/server.properties
	readGreen 1 'Is everything okay? (Y/n)' menuOK
	if [[ $menuOK == "n" || $menuOK == "N" ]]; then
		while [[ -z $armageddon ]]; do
			numberPrompt "Redo server properties" "Quit" "Just kidding! Continue"
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
					exit 0
					;;
				3)
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
########## TESTS ###############
testExit "[[ ! $(which apt) ]]" "This script is intended for Debian/Ubuntu and requires APT, but couldn't find it." 90
testExit "[[ $EUID -ne 0 ]]" "You need to be root (sudo -s)" 91
testExit "[[ $megsFree -lt 2000 ]]" "Not really enough hard drive space free. Umm... try getting like 2GB" 92
testExit "[[ $ramFree -lt 512]]" "Download more ram (min: 512MB free, you have $ramFree)" 93
########## EXECUTION ###########
clear
echo -e "\e[1;35mHiiii! This is Pink Wool, an interactive installer for Minecraft!\e[0m\n"
echo -e "This program runs destructively, expecting a completely fresh install of Ubuntu. Don't run it on an existing system, please! Weird things could happen.\n"
echo -e "(Also, by running this, you \e[0;34magree to the Minecraft eula\e[0m, so make sure you read it!)\n"
echo -e "\e[1;31mPush CTRL+C at any time to quit!\e[0m"
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
while [[ -z $downloadJar ]]; do
	numberPrompt "Vanilla" "Paper"
		readGreen 1 "Choose a Minecraft variant" downloadJar
		case $downloadJar in 
			1 | '')
				downloadJar="Vanilla"
				downloadEval="wget $jarfileURL"
			;;
			2)
				downloadJar="Paper"
				downloadEval="wget $paperURL && mv paper-* server.jar"
			;;
			*)
				echo $BADNUMBER
				unset downloadJar
			;;
		esac
done
# ask for and set server.properties now
readGreen 1 'Do you want to configure server.properties now? (Y/n)' goConfig
if [[ $goConfig != "n" && $goConfig != "N" ]]; then
	serverProps
fi
# basic setup
mkdir -p /var/opt/minecraft/www/admin/
cd /var/opt/minecraft
cat <<EODEFAULT > server.properties
#Minecraft server properties
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
enable-rcon=false
EODEFAULT
# turn on rcon, apply server properties from earlier
sed -i "s/^enable-rcon=false/enable-rcon=true/" server.properties
sed -i "s/^rcon\.password=/rcon\.password=${rconPass}/" server.properties
if [[ $goConfig != "n" && $goConfig != "N" ]]; then
	allProps
fi
# menu test
showVars
while [[ $watchman ]]; do
	showVars
done
# jar file
eval $downloadEval
useradd -r -m -U -d /var/opt/minecraft -s /bin/false minecraft
# getting dependencies
apt update -y
apt upgrade -y
apt install -y $DEPENDENCIES
/usr/bin/java -Xms${dedotated}M -Xmx${dedotated}M -jar /var/opt/minecraft/server.jar nogui
# should be eula.txt here now
testExit '[[ ! -w "eula.txt" ]]' "Something weird happened... there should be a writeable eula.txt here and there isn't. Maybe that means java didn't run successfully. Sorry, but this error is super fatal! Quitting~" 99
chown -R minecraft:minecraft /var/opt/minecraft
# firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow 443
ufw allow ssh
ufw allow 25565
ufw allow from 127.0.0.1 to any port 25575
service ufw restart
# agree to eula
sed -i 's/^eula=false/eula=true/' eula.txt
# installs cronjobs if they were requested
backupCron
makeService
# get mcrcon
wget https://github.com/Tiiffi/mcrcon/releases/download/v${mcrconVersion}/mcrcon-${mcrconVersion}-linux-x86-64.tar.gz
tar xf mcrcon-${mcrconVersion}-linux-x86-64.tar.gz
cp mcrcon-${mcrconVersion}-linux-x86-64/mcrcon /usr/bin/mcrcon
rm -r mcrcon-*
# don't use eval here; it seems to be too slow
service minecraft start
testExit "[[ $? -gt 0 ]]" "Oh no... system service! Why??" 97
# get caddy 
wget https://github.com/caddyserver/caddy/releases/download/v${caddyVersion}/caddy_${caddyVersion}_linux_amd64.deb
dpkg -i caddy_${caddyVersion}_linux_amd64.deb
rm caddy_${caddyVersion}_linux_amd64.deb
httpPass=$(caddy hash-password --plaintext "$httpPass")
cat <<EOC > /etc/caddy/Caddyfile
$ipAddrShow, $serverHostname
root * /var/opt/minecraft/www
file_server 
php_fastcgi unix//run/php/php7.4-fpm.sock
basicauth /admin/* {
	$httpUser $httpPass
}
EOC
echo '$ a www-data ALL=(ALL) NOPASSWD:/usr/sbin/service minecraft*' | EDITOR="sed -f- -i" visudo
# make the site
# index
newPHP "/var/opt/minecraft/www/index.php" "Pink Wool Minecraft Server" "Hiiii~"
cat <<EOSITE >> /var/opt/minecraft/www/index.php
	<p>Welcome to your Pink Wool minecraft server page! This page is located under /var/opt/minecraft/www/ </p>
	<p><a href="admin/index.php">Admin panel</a></p>
$HTMLEND
EOSITE
# panel
newPHP "/var/opt/minecraft/www/admin/index.php" "Pink Wool admin panel" "Pink Wool admin panel"
cat <<EOPANEL >> /var/opt/minecraft/www/admin/index.php
	<?php
		exec("sudo /usr/sbin/service minecraft status",\$out,\$err);
		echo '<h2>Backend status:</h2><ol>';
		foreach (\$out as \$o) {
			echo "<li>\$o</li>";
		}
	?>
	</ol>
	<hr>
	<h2>Backups</h2>
	<?php
		\$zipfiles = glob('/var/opt/minecraft/www/admin/backups/*.zip');
		if (isset(\$zipfiles)) {
			echo '<ul>';
			foreach (\$zipfiles as \$zip) {
				\$z=basename(\$zip);
				echo "<li><a href='/admin/backups/\$z'>\$z</a></li>";
			}
		}
	?>
	</ul>
	<p><a href="backup.php">Run a backup</a></p>
	<hr>
	<h2>Controls (Warning: These are slow!)</h2>
	<p><a href="service.php?do=start">Start Minecraft</a></p>
	<p><a href="service.php?do=stop">Stop Minecraft</a></p>
	<p><a href="service.php?do=restart">Restart Minecraft (stop then start)</a></p>
$HTMLEND
EOPANEL
# start/stop/restart
newPHP "/var/opt/minecraft/www/admin/service.php" "Pink Wool control panel" "service.php"
cat <<EOSERVICE >> /var/opt/minecraft/www/admin/service.php
	<?php
		\$action = htmlspecialchars(\$_GET["do"]);
		if (!in_array(\$action, ['start','restart','stop'], true )) {
			exit(2);
		}
		exec("sudo /usr/sbin/service minecraft \$action",\$out,\$err);
		if (\$err == 0) {
			echo "<h2>\$action command sent successfully...</h2>";
			echo "<p>This means the server is now attempting to \$action Java and Minecraft. It could take a long time, depending on your system's speed. Check the admin panel to see the server's status.</p>";
			echo '<p><a href="index.php">Back to panel</a><p>';
		} 
		else {
			echo "<h2>Error</h2><p>Exit code: \$err</p>";
		}
	?>
$HTMLEND
EOSERVICE
# backup
newPHP "/var/opt/minecraft/www/admin/backup.php" "Pink Wool control panel - Backup" "backup.php"
cat <<EOBACK >> /var/opt/minecraft/www/admin/backup.php
	<?php
		exec("/usr/bin/zip -r /var/opt/minecraft/www/admin/backups/minecraft-\$(date +%F)-manual.zip /var/opt/minecraft/ -x \\*.sh -x minecraft\\*.zip",\$out,\$err);
		if (\$err >= 1) {
			echo "<h2>Zip error (exit status \$err)</h2>";
		}
		else {
			echo '<h2>Backup complete!</h2><p><a href="index.php">Back to panel</a><p>';
		}
	?>
$HTMLEND
EOBACK
cat <<EOCSS >> /var/opt/minecraft/www/pink-wool.css
body {
	background: linear-gradient(#ffe9f0,75%,#ff4d6e);
	background-attachment: fixed;
	color: black;
	font-family: Arial,Helvetica,"Liberation Sans",sans-serif;
	font-size: 16px;
	margin: 2em auto;
	max-width: 800px;
}
h1 {
	font-family: "Lucida Console",monospace;
}
a {
	text-decoration: none;
	color: #0623c4;
}
footer ul {
	font-size: 12px;
	list-style-type: none;
	padding: 0px;
}
footer ul li {
	text-align: left;
	display: inline-block;
	width: 33%;
}
EOCSS
service caddy restart
echo 'Waiting for Minecraft to finish world generation...'
i=0
while [[ -z $worldDone ]]; do
	service minecraft status | grep 'RCON running'
	if [[ $? -eq 0 ]]; then
		worldDone=true
		break
	else
		sleep 10
				((i+=10))
				echo "$i seconds..."
	fi
done
chown -R minecraft:www-data /var/opt/minecraft
chmod -R 770 /var/opt/minecraft/www/admin/backups
# apparently this is needed or occasionally you'll try to op before minecraft is ready
sleep 2
/usr/bin/mcrcon -p "$rconPass" "op $mcUser"
testExit "[[ $? -gt 0 ]]" 'Something went wrong right at the end??' 98
victory
