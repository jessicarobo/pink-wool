#!/bin/bash
# Pink Wool install script for Debian 11 (bullseye)
dependencies="ufw zip php-fpm sudo java-common libasound2 libxi6 libxrender1 libxtst6 libfontconfig1"
getCaddy="true"
CADDYVERSION="2.3.0"
javaDeb="zulu16.30.15-ca-jre16.0.1-linux_amd64.deb"
if [[ $PWNOPANEL ]]; then
	dependencies="java-common libasound2 libxi6 libxrender1 libxtst6 libfontconfig1"
	unset getCaddy
fi
if [[ ! $(which apt) ]]; then 
	echo "This script is intended for 64bit Debian/Ubuntu and requires APT, but couldn't find it." 
	exit 90
fi
echo "Using 'bullseye.sh' to run APT and dpkg commands..."
apt update -y ##&> /dev/null
if [[ $dependencies ]]; then
    apt install -y $dependencies ##&> /dev/null
fi
echo -e "$GOK"
echo "Getting Java 16 from Azul..."
wget "https://cdn.azul.com/zulu/bin/${javaDeb}" ##&> /dev/null
dpkg -i ${javaDeb} ##&> /dev/null
rm ${javaDeb} ##&> /dev/null
if [[ ! $(which java) ]]; then 
	echo "Failed to install dependencies (Java not found)"
	exit 106
fi
echo -e "$GOK"
if [[ $getCaddy ]]; then
    echo "Getting Caddy webserver..."
	wget "https://github.com/caddyserver/caddy/releases/download/v${CADDYVERSION}/caddy_${CADDYVERSION}_linux_amd64.deb" ##&> /dev/null
	dpkg -i caddy_${CADDYVERSION}_linux_amd64.deb ##&> /dev/null
	rm caddy_${CADDYVERSION}_linux_amd64.deb ##&> /dev/null
    if [[ ! $(which caddy) ]]; then 
        echo "Failed to install dependencies (Caddy not found)"
        exit 106
    fi
    echo -e "$GOK"
fi
exit 0
