# pink-wool
BASH installation script and simple control panel for Minecraft

This can:
- Install Minecraft as a service on a 64-bit apt-based Linux server
- Configure some of server.properties
- Create daily .zip backups
- Create a web-based control panel

## When would I use this?
When:
- You have a brand new Ubuntu (or equivalent, specifically with APT) Linux server 
- You plan to use it for **only** 1 Minecraft server and 
- You don't care if this script runs destructively, changing whatever it wants to change. 

Running this to reinstall Minecraft might not work, and would be unwise!

The actual server administration uses [mcrcon](https://github.com/Tiiffi/mcrcon), which will be downloaded as part of the install process. RCON itself is firewalled so that it is only available through the control panel

The control panel is a [Caddy](https://caddyserver.com) HTTPS server hosting a few PHP files with basic auth. If you don't have a fully qualified domain name, your cert will be self-signed but functioning. HTTPS is crucial for this setup to be secure.

Tested and working on:
- Ubuntu 20.04 LTS (recommended)
- Ubuntu 21.04
- Mint 20.1

Won't work on:
- Debian 10 (repositories have Java 11 instead of 16)
- Debian 11 (repositories have Java 17 instead of 16)

## Installation

You will need to be root for the installation.

`sudo -s`

`wget https://raw.githubusercontent.com/jessicarobo/pink-wool/main/pink-wool.sh`

`chmod 700 pink-wool.sh`

`./pink-wool.sh`

It will ask you a number of questions for the control panel and for server.properties, then it should just run until finished.

For post-install configuration, most of the relevant files will be in /var/opt/minecraft/

## To-do

- commandline arguments
- tutorial video
- uninstaller
- updater
- ability to input rcon commands directly into the web panel
- implement (programmer word meaning "steal") xpaw's status php
- broader distro support

## Changelog

### v0.3
- More consistent code style (e.g. camelCase variables)
- Web panel UI redesign
- More input validation in the installer
- Installer lets the user retry/quit/continue
- Installer understands server.properties defaults
- Installer has a lot of new cute colors!
- No longer leaves source .tar.gz or .deb files lying around


### v0.2
- Can force a backup at any time through the web panel
- Web panel shows partial server status
- Panel supports start and stop commands instead of just restart
- Installer supports [Paper](https://papermc.io)
- Downloads a binary release for mcrcon instead of compiling it, resulting in fewer dependencies
- Fixed a bug where op level wasn't being written to server properties
- Minecraft now launches with the same value for minimum and maximum heap size
- Downloads Java 16 instead of 11
- Tab indents instead of spaces 😼
- Generally more readable code
- Slightly less pink page background 🌸

### v0.1
- Initial version!
- Installs vanilla MC
- Installs a control panel with built-in HTTPS

## Contact
Please get in touch if you have comments 
- Jessica ^O^ https://r0b0.org
