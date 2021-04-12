# pink-wool
BASH installation script and simple control panel for Minecraft

## When would I use this?
When:
- You have a brand new Ubuntu (or equivalent) Linux server 
- You plan to use it for **only** 1 Minecraft server and 
- You don't care if this script changes whatever it wants to change. 

Running this to reinstall Minecraft might not work and would be unwise!

The actual server administration uses mcrcon (https://github.com/Tiiffi/mcrcon), which will be downloaded as part of the install process.

The control panel is a Caddy HTTPS server hosting a few PHP files with basic auth. If you don't have a fully qualified domain name, your cert will be self-signed. HTTPS is crucial for this setup to be secure.

## Installation

You will need to be root for the installation.

`sudo -s`

`wget https://raw.githubusercontent.com/jessicarobo/pink-wool/main/pink-wool.sh`

`chmod 700 pink-wool.sh`

`./pink-wool.sh`

It will ask you a number of questions for the control panel and for server.properties, then it should just run until finished.

For post-install configuration, most of the relevant files will be in /var/opt/minecraft/

## todo

better readme

more sanitization and error checking on the interactive parts of the script

commandline options

more options in the control panel

## Contact
Please get in touch if you have comments 
- Jessica ^O^ https://r0b0.org
