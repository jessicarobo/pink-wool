# pink-wool
BASH installation script and simple control panel for Minecraft

This can:
- Install Minecraft as a service on a 64-bit Ubuntu Linux server
- Configure some of server.properties
- Create daily .zip backups
- Create a web-based control panel

## When would I use this?
When:
- You have a brand new Ubuntu (or equivalent, specifically with APT and Java 16 available) Linux server 
- You plan to use it for **only** 1 Minecraft server and 
- You don't care if this script runs destructively, changing whatever it wants to change. 

Running this to reinstall Minecraft might not work, and would be unwise!

The control panel is a [Caddy](https://caddyserver.com) HTTPS server hosting a few PHP files with basic auth. If you don't have a fully qualified domain name, your cert will be self-signed but functioning.

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

`wget https://raw.githubusercontent.com/jessicarobo/pink-wool/main/pink-wool.sh -O -`

It will ask you a number of questions for the control panel and for server.properties, then it should just run until finished.

![pink-wool installer](pink-wool-install.png)

For post-install configuration, most of the relevant files will be in `/var/opt/minecraft/`.

![pink-wool admin panel](pink-wool-panel.png)

## To-do

- commandline arguments
- tutorial video
- uninstaller
- updater
- ability to input rcon commands directly into the web panel, at the very least `say` and `op`
- implement (programmer word meaning "steal") xpaw's status php
- broader distro support (get Java for both Debians and later Ubuntus)
- More consistent style (no colons after questions)
- Use arrays! Use functions! Clean things more...
- Put php header/footer into their own files and source those instead of outputting a variable
- https://blog.ulysse.io/post/minecraft-server-with-backups-via-systemd/ named pipes might let us get rid of rcon

## Changelog

### v1.0.0
-Semantic versioning (this is the update after v0.3)
-Modular design: instead of one large shell script with everything in it, the PHP/HTML/CSS is separated out
-Modular design (more): the installer fetches a shell script for the user's specific linux distribution

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
