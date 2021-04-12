#!/bin/bash
# pink-wool.sh minecraft installer v0.1
# by Jessica Robo~
#
# Comment or remove this next line for other OSes (untested but I might add them later)
UBUNTUCHECK="true"
# Change this if you want a different version of minecraft, but make sure you save it as server.jar
jarfileURL="https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar"
# Other variables -- you probably don't need to change these
rconpass=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c6)
BADNUMBER="Invalid response. Please enter a number."
ipaddrshow=$(ip addr show | grep global | grep -oe "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | head -n 1 )
servermotd="A Pink Wool server \u00A7d^O^"
#
#
# check for root
if [[ $EUID -ne 0 ]]; then
  echo 'You need to be root (sudo -s)'
  exit 91
fi
# check for ubuntu
if [[ $UBUNTUCHECK == "true" ]]; then
    if [[ ! $(grep "Ubuntu" /etc/issue) ]]; then
    echo 'this is only tested on ubuntu'
    echo 'if you think it might work anyway and want to try it out (e.g. on debian or mint), edit this script to remove the UBUNTUCHECK line at the top'
    exit 90
    fi
fi
# check for space
megsfree=$(df -BM | grep -e "/$" | awk '{print $4}' | grep -oe '[0-9]*')
if [[ $megsfree -lt 2000 ]]; then
  echo "Not really enough hard drive space. Umm... try getting like 2GB"
  exit 92
fi
# and for ram
ramfree=$(free -m | grep 'Mem:' | awk '{print $2}')
dedotated=$(expr $ramfree - 200)
if [[ $ramfree -lt 512 ]]; then
  echo "Download more ram (min: 512MB, you have $dedotated)"
  exit 93
fi
minram=256
if [[ $dedotated -gt 1536 ]]; then
  minram=1024
fi
function numberPrompt() {
  #numberPrompt OPTION1 OPTION2 OPTION3 ...
  i=1
  echo ''
  while [[ -n $1 ]]; do
    echo "$i) $1"
    ((i++))
    shift 1
  done
}
function makeSite() {
# index
cat <<EOSITE > /var/opt/minecraft/www/index.php
<!DOCTYPE html>
<html>
<head>
<title>Pink Wool Minecraft Server</title>
<meta name="viewport" content="width=device-width">
<link rel="stylesheet" href="/pink-wool.css">
</head>
<body>
<h1>Hiiii~</h1>
<p>Welcome to your Pink Wool minecraft server page! This page is located under /var/opt/minecraft/www/ </p>
<p><a href="admin/index.php">Admin panel</a></p>
</body>
</html>
EOSITE
# panel
cat <<EOPANEL > /var/opt/minecraft/www/admin/index.php
<!DOCTYPE html>
<html>
<head>
<title>Pink Wool admin panel</title>
<meta name="viewport" content="width=device-width">
<link rel="stylesheet" href="/pink-wool.css">
</head>
<body>
<h1>Pink Wool admin panel</h1>
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
  echo '</ul>';
}
?>
<hr>
<p><a href="restart.php">Restart Minecraft</a></p>
</body>
</html>
EOPANEL
# restart
cat <<EORESTART > /var/opt/minecraft/www/admin/restart.php
<!DOCTYPE html>
<html>
<head>
<title>Pink Wool control panel</title>
<meta name="viewport" content="width=device-width">
<link rel="stylesheet" href="/pink-wool.css">
</head>
<body>
<?php
exec("sudo /usr/sbin/service minecraft restart",\$out,\$err);
if (\$err == 0) {
echo '<h2>Restart command sent successfully...</h2><p>Please wait a few minutes.</p>';
}
else {
echo '<h2>Error</h2><p>Exit code: \$err</p>';
}
?>
</body>
</html>
EORESTART
cat <<EOCSS > /var/opt/minecraft/www/pink-wool.css
body {
	background: linear-gradient(#f7def0,66%, #df2c4e);
	background-attachment: fixed;
	color: black;
	font-family: Arial,Helvetica,"Liberation Sans",sans-serif;
	font-size: 16px;
	margin: 2em auto;
	max-width: 800px;
	padding: 1em;
}
h1 {
  font-family: "Lucida Console",monospace;
}
a {
    text-decoration: none;
    color: #0623c4;
}
EOCSS
}
function victory() {
echo -e "\033[0;32mMinecraft is installed and running (pid $(pidof java))! \033[0;35m^O^\033[0m"
echo -e "Thank you for using \033[1;35mPink Wool\033[0m! If you installed the \033[0;34mcontrol panel\033[0m, it should be available now (https://${ipaddrshow})"
exit 0
}
function serverProps() {
echo ''
read -e -n 1 -p "Do you want to configure server.properties now? (Y/n) " goconfig
  if [[ $goconfig == "n" || $goconfig == "N" ]]; then
  echo ''
    return 0
  fi
  # gamemode
  numberPrompt survival creative adventure spectator
  read -e -n 1 -p "Choose a gamemode: " gamemodenum
  case $gamemodenum in
    1)
      gamemode="survival"
    ;;
    2)
      gamemode="creative"
    ;;
    3)
      gamemode="adventure"
    ;;
    4)
      gamemode="spectator"
    ;;
    *)
      echo "$BADNUMBER"
    ;;
  esac
  # max players
  read -e -n 3 -p "Enter maximum player count: " playercount
  while [ $playercount -lt 1 ]; do
    echo "Player count has to be a positive number"
    read -e -p "Enter maximum player count: " playercount
  done
  # seed
  read -e -n 512 -p $'Enter a seed, if you like!\n' worldseed
  # motd
  read -e -n 60 -p $'Enter your MOTD (60 characters):\n' servermotd
  # whitelist
  numberPrompt "true" "false"
  read -n 1 -p "Enforce whitelist? " whitelistOn
  # command blocks
  numberPrompt "true" "false"
  read -n 1 -p "Enable command blocks? " cmdblockOn
  # pvp
  numberPrompt "true" "false"
  read -n 1 -p "Enable pvp? " pvpOn
  
  # difficulty
  while [[ -n $difficulty ]]; do
    numberPrompt "peaceful" "easy" "normal" "hard"
    read -n 1 -p "Choose a difficulty:" difficultynum
    case $difficultynum in
      1)
        difficulty="peaceful"
      ;;
      2)
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
  numberPrompt "bypass spawn protection" "cheats and command blocks" "ban/op" "all commands"
  read -n 1 -p "Choose op permission level: " oplevel
  case $oplevel in
    1 | 2 | 3 | 4)
    ;;
    *)
      echo "$BADNUMBER"
    ;;
  esac
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
/usr/bin/java -Xms${minram}M -Xmx${dedotated}M -XX:+UseG1GC -jar /var/opt/minecraft/server.jar nogui
EOA
cat << EOB > /var/opt/minecraft/minecraft-stop.sh
#!/bin/bash
/usr/bin/mcrcon -p $rconpass -w 3 'say shutting down...' save-all stop
EOB
chmod 700 /var/opt/minecraft/minecraft-st*
systemctl daemon-reload
chown -R minecraft:minecraft /var/opt/minecraft
}
function whatyoused() {
  sed -i 's/^eula=false/eula=true/' eula.txt
  sed -i "s/^enable-rcon=false/enable-rcon=true/" server.properties
  sed -i "s/^rcon\.password=/rcon\.password=${rconpass}/" server.properties
  if [[ $goconfig == "n" || $goconfig == "N" ]]; then
    return 0
  fi
  sed -i "s/^gamemode=survival/gamemode=${gamemode}/" server.properties
  sed -i "s/^max-players=20/max-players=${playercount}/" server.properties
  sed -i "s/^motd=A Minecraft Server/motd=${servermotd}/" server.properties
  sed -i "s/^level-seed=/level-seed=${worldseed}/" server.properties
  sed -i "s/^enforce-whitelist=false/enforce-whitelist=${whitelistOn}/" server.properties
  sed -i "s/^enable-command-block=false/enable-command-block=${cmdblockOn}/" server.properties
  sed -i "s/^pvp=true/pvp=${pvpOn}/" server.properties
}
function backupCron() {
  if [[ $backupMinute -ge 0 ]]; then
    mkdir /var/opt/minecraft/www/admin/backups
    echo "$backupMinute $backupHour * * * minecraft /usr/bin/zip -r /var/opt/minecraft/www/admin/backups/minecraft-\$(date +%F).zip /var/opt/minecraft/world/" > /etc/cron.d/minecraft-backup
    echo '55 23 * * * minecraft  /usr/bin/find /var/opt/minecraft/www/admin/backups/ -name "*.zip" -type f -mtime +7 -delete' >> /etc/cron.d/minecraft-backup
  fi
  return 0
}
function debugWait() {
  # debugWait $SECONDS $ID
  echo "Waiting for debug purposes. Param: $2"
  sleep $1
  return 0
}
#
# echo intro
#
clear
echo -e "Hiiii! This is Pink Wool, an interactive installer for Minecraft. This program runs destructively, expecting a fresh install of Ubuntu without Minecraft. Don't run it on an existing system please!\n\n(also, by running this, you agree to the Minecraft eula, so make sure you read it!)"
sleep 2s
echo "We will need to know a few things to get started..."
# hostname
read -e -p $'\nFirst, your domain name. This is like minecraft.example.com. Leave it blank if you don\'t have one:\n' serverhostname
if [[ -z $serverhostname ]]; then
  serverhostname='localhost'
fi
# minecraft username
read -e -p $'Enter your Minecraft username so you can be opped/whitelisted:\n' mcuser
# https username
read -e -p $'Choose a username for the web control panel (for example, "Admin" or "Jessica"):\n' httpuser
if [[ -z $httpuser ]]; then
  httpuser='Admin'
fi
# https password
while [[ -z $httppass ]]; do
  read -s -p $'Choose a password for the web control panel:\n' passguyone
  read -s -p $'Type your password again to confirm:\n' passguytwo
  if [[ $passguyone == $passguytwo ]]; then
    httppass=$passguyone
  else
    echo "Passwords didn't match."
    sleep 1
  fi
done
read -n 1 -p $'Do you want daily backups? y/N\n' backupOn
  if [[ $backupOn == "Y" || $backupOn == "y" ]]; then
    echo ''
    read -n 5 -p "When? (00:00-23:59) " backupTime
    backupHour=$(echo $backupTime | cut -d : -f 1)
    backupHour=${backupHour#0}
    if [[ $backupHour -gt 23 ]]; then
      backupHour=23
    fi
    backupMinute=$(echo $backupTime | cut -d : -f 2)
    backupMinute=${backupMinute#0}
    if [[ $backupMinute -gt 59 ]]; then
      backupHour=59
    fi
  fi
# ask for and set server.properties now
serverProps
# basic setup
mkdir -p /var/opt/minecraft/www/admin/
useradd -r -m -U -d /var/opt/minecraft -s /bin/false minecraft
# getting dependencies
apt update -y
apt upgrade -y
apt install -y git build-essential openjdk-11-jre-headless ufw zip php-cli php-fpm
cd /var/opt/minecraft
git clone https://github.com/Tiiffi/mcrcon.git
cd mcrcon
gcc -std=gnu11 -pedantic -Wall -Wextra -O2 -s -o mcrcon mcrcon.c
cp mcrcon /usr/bin/mcrcon
#
# todo: select version
cd /var/opt/minecraft
rm server.jar &> /dev/null
echo 'Getting 1.16.5'
wget $jarfileURL 
/usr/bin/java -Xms${minram}M -Xmx${dedotated}M -jar /var/opt/minecraft/server.jar nogui
# should be eula.txt here now
if [[ ! -w "eula.txt" ]]; then
  echo -e "Something weird happened... there should be a writeable eula.txt here and there isn't.\nMaybe that means java didn't run successfully. Sorry, but this error is super fatal! Quitting~"
  exit 99
fi
chown -R minecraft:minecraft /var/opt/minecraft
# firewall
#
ufw default deny incoming
ufw default allow outgoing
ufw allow 443
ufw allow ssh
ufw allow 25565
ufw allow from 127.0.0.1 to any port 25575
service ufw restart
#
# agree to eula, turn on rcon, apply server properties from earlier
whatyoused
# installs cronjobs if they were requested
backupCron
makeService
service minecraft start
if [[ $? -gt 0 ]]; then
  echo 'Oh no... system service why?'
  exit 97
fi
#get caddy 
wget https://github.com/caddyserver/caddy/releases/download/v2.3.0/caddy_2.3.0_linux_amd64.deb
dpkg -i caddy_2.3.0_linux_amd64.deb
#
httppass=$(caddy hash-password --plaintext "$httppass")
cat <<EOC > /etc/caddy/Caddyfile
$ipaddrshow, $serverhostname
root * /var/opt/minecraft/www
file_server 
php_fastcgi unix//run/php/php7.4-fpm.sock
basicauth /admin/* {
  $httpuser $httppass
}
EOC
echo '$ a www-data ALL=(ALL) NOPASSWD:/usr/sbin/service minecraft restart' | EDITOR="sed -f- -i" visudo
makeSite
service caddy restart
echo 'Waiting for minecraft to finish world generation...'
while [[ -z $worlddone ]]; do
  service minecraft status | grep 'Done'
  if [[ $? -eq 0 ]]; then
    worlddone=true
    break
  else
    sleep 10
  fi
done
chown -R minecraft:minecraft /var/opt/minecraft
# apparently this is needed or occasionally you'll try to op before minecraft is ready
sleep 2
/usr/bin/mcrcon -p $rconpass "op $mcuser" && clear
if [[ $? -gt 0 ]]; then
  echo 'Something went wrong right at the end??'
  exit 98
fi
victory
