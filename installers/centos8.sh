#!/bin/bash
# Pink Wool installer for Centos 8
getCaddy="true"
javaRpm="zulu16.30.15-ca-jre16.0.1-linux.x86_64.rpm"
dependencies="zip php-fpm php-cli"
if [[ $PWNOPANEL ]]; then
	unset dependencies
	unset getCaddy
fi
if [[ ! $(which dnf) ]]; then 
	echo "This script is intended for CentOS and requires dnf, but couldn't find it." 
	exit 90
fi
echo "Using 'centos8.sh' to run dnf..."
if [[ $dependencies ]]; then
	dnf install -y $dependencies &> /dev/null
fi
echo -e "$GOK"
echo "Getting Java 16 from Azul..."
curl "https://cdn.azul.com/zulu/bin/${javaRpm}" -o ${javaRpm} ##&> /dev/null
rpm -i ${javaRpm} ##&> /dev/null
rm ${javaRpm} &> /dev/null
if [[ ! $(which java) ]]; then 
	echo "Failed to install dependencies (Java not found)"
	exit 106
fi
echo -e "$GOK"
if [[ $getCaddy ]]; then
	echo "Getting Caddy webserver..."
	dnf copr enable -y @caddy/caddy
	dnf install -y caddy
	if [[ ! $(which caddy) ]]; then 
		echo "Failed to install dependencies (Caddy not found)"
		exit 106
	fi
	echo -e "$GOK"
fi
exit 0
