#!/bin/bash
dependencies="ufw zip php-fpm"
getCaddy="true"
$javaURL="https://download.java.net/java/GA/jdk16.0.1/7147401fd7354114ac51ef3e1328291f/9/GPL/openjdk-16.0.1_linux-x64_bin.tar.gz"
if [[ $PWNOPANEL ]]; then
	unset dependencies
	unset getCaddy
fi
if [[ ! $(which apt) ]]; then 
	echo "This script is intended for 64bit Debian/Ubuntu and requires APT, but couldn't find it." 
	exit 90
fi
echo "Using 'buster.sh' to run APT and dpkg commands..."
apt update -y &> /dev/null
if [[ $dependencies ]]; then
    apt install -y $dependencies &> /dev/null
fi
echo -e "$GOK"
echo "Getting Java 16 from Azul..."
wget https://cdn.azul.com/zulu/bin/zulu16.30.15-ca-jre16.0.1-linux_amd64.deb &> /dev/null
dpkg -i zulu16.30.15-ca-jre16.0.1-linux_amd64.deb &> /dev/null
rm zulu16.30.15-ca-jre16.0.1-linux_amd64.deb &> /dev/null
if [[ ! $(which java) ]]; then 
	echo "Failed to install dependencies (Java not found)"
	exit 106
fi
echo -e "$GOK"
if [[ $getCaddy ]]; then
    echo "Getting Caddy webserver..."
	wget https://github.com/caddyserver/caddy/releases/download/v${CADDYVERSION}/caddy_${CADDYVERSION}_linux_amd64.deb &> /dev/null
	dpkg -i caddy_${CADDYVERSION}_linux_amd64.deb &> /dev/null
	rm caddy_${CADDYVERSION}_linux_amd64.deb &> /dev/null
    if [[ ! $(which caddy) ]]; then 
        echo "Failed to install dependencies (Java not found)"
        exit 106
    fi
    echo -e "$GOK"
fi
exit 0
