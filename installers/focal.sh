#!/bin/bash
DEPENDENCIES="openjdk-16-jre-headless ufw zip php-fpm"
caddyVersion="2.3.0"
if [[ ! $(which apt) ]]; then 
	echo "This script is intended for Debian/Ubuntu and requires APT, but couldn't find it." 
	exit 90
fi
echo "Using 'focal.sh' to run APT and dpkg commands..."
apt update -y &> /dev/null
apt upgrade -y &> /dev/null
apt install -y $DEPENDENCIES &> /dev/null
# get caddy 
wget https://github.com/caddyserver/caddy/releases/download/v${caddyVersion}/caddy_${caddyVersion}_linux_amd64.deb &> /dev/null
dpkg -i caddy_${caddyVersion}_linux_amd64.deb &> /dev/null
rm caddy_${caddyVersion}_linux_amd64.deb &> /dev/null
if [[ ! $(which java) ]]; then 
	echo "Failed to install dependencies (Java not found)"
	exit 106
fi
echo "OK!"
exit 0
