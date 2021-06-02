#!/bin/bash
DEPENDENCIES="openjdk-16-jre-headless ufw zip php7.4-fpm"
testExit "[[ ! $(which apt) ]]" "This script is intended for Debian/Ubuntu and requires APT, but couldn't find it." 90
apt update -y
apt upgrade -y
apt install -y $DEPENDENCIES
# get caddy 
wget https://github.com/caddyserver/caddy/releases/download/v${caddyVersion}/caddy_${caddyVersion}_linux_amd64.deb
dpkg -i caddy_${caddyVersion}_linux_amd64.deb
rm caddy_${caddyVersion}_linux_amd64.deb