c710_ubuntu_pis
===============

Acer C710 Ubuntu 14.04 Post Installation Script. 

You are welcome to change or modify this script as you see fit. I just ask if you repost this somewhere, please give me credit. I will not provide support because I have limited time, which is why I created this script. Use this script at your own risk. I am not responsible for messed up installations, exploding computers,  etc...

Installation Notes:
```
cd ~/Downloads
wget -O install.sh http://goo.gl/vpWkAZ
sudo sh install.sh
```
Options Detailed:

1. Install touchpad modules: Loads the modules required for the touchpad.
2. Configure the touchpad settings so it is smoother and it fixes problems with it on battery. [Can be adjusted](https://johnlewis.ie/mediawiki/index.php?title=Ubuntu_Post_Installation)
3. Configure CrOs flashrom so user can use flashrom to flash a new bios.
4. Enable hibernation and suspend the cyapa module to fix issue on hibernation resume.
5. Configure Intel P-state. [More info](http://www.webupd8.org/2014/04/prevent-your-laptop-from-overheating.html)
6. Install [thermald](https://01.org/linux-thermal-daemon/documentation/introduction-thermal-daemon)
7. Install [tlp](http://linrunner.de/en/tlp/tlp.html)
8. Install xbacklight and configure keyboard shortcuts manually
9. Installs:
  1. [restricted extras](https://en.wikipedia.org/wiki/Ubuntu-restricted-extras)
  2. [powertop](https://01.org/powertop)
  3. [htop](http://hisham.hm/htop/)
  4. [system load indicator](https://apps.ubuntu.com/cat/applications/precise/indicator-multiload/)
  5. [synaptic] (https://apps.ubuntu.com/cat/applications/synaptic/)
10. Download and install Chrome Browser
11. Download and install [indicator sensors](https://launchpad.net/~alexmurray/+archive/ubuntu/indicator-sensors)
12. Install [Oracle Java 7](http://www.webupd8.org/2012/01/install-oracle-java-jdk-7-in-ubuntu-via.html)
13. Install [My weather indicator](https://launchpad.net/my-weather-indicator)
14. Install [wine](https://en.wikipedia.org/wiki/Wine_(software)) and [Playonlinux](http://www.playonlinux.com/en/)
15. Install [Intel Graphics Driver](https://01.org/linuxgraphics/)
16. Configure system for a SSD by adding noatime and nodiratime to fstab and creating a daily cron job to trim the SSD. Trim output logs at var/log/trim.log
17. Install [Virtualbox](https://www.virtualbox.org/)
18. Installs [XBMC/KODI](http://xbmc.org/)
19. Installs [pipelight](https://launchpad.net/pipelight) and enables silverlight plug-in
20. Installs [Timeshift](http://www.teejeetech.in/p/timeshift.html)
21. Installs [Dropbox](https://www.dropbox.com/)
22. Check for system updates by running apt-get update and apt-get dist-upgrade
