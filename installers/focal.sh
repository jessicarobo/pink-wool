#!/bin/bash
dependencies="openjdk-16-jre-headless zip php-fpm"
getCaddy="true"
if [[ $PWNOPANEL ]]; then
	dependencies="openjdk-16-jre-headless"
	unset getCaddy
fi
if [[ ! $(which apt) ]]; then 
	echo "This script is intended for 64bit Debian/Ubuntu and requires APT, but couldn't find it." 
	exit 90
fi
echo -n "Using 'focal.sh' to run APT and dpkg commands... "
apt update -y &> /dev/null
apt install -y $dependencies &> /dev/null
echo -e "$GOK"
# get caddy 
if [[ $getCaddy ]]; then
	echo -n "Getting Caddy webserver... "
	wget https://github.com/caddyserver/caddy/releases/download/v${CADDYVERSION}/caddy_${CADDYVERSION}_linux_amd64.deb &> /dev/null
	dpkg -i caddy_${CADDYVERSION}_linux_amd64.deb &> /dev/null
	rm caddy_${CADDYVERSION}_linux_amd64.deb &> /dev/null
	echo -e "$GOK"
fi
if [[ ! $(which java) ]]; then 
	echo "Failed to install dependencies (Java not found)"
	exit 106
fi
exit 0
