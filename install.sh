#!/bin/bash
#Acer C710 Ubuntu Post-Installation Script
clear
echo -e "This script will configure a fresh install of Ubuntu 14.04 on an Acer C710.\nI have tested it so far on Ubuntu 14.04 and Xubuntu 14.04 and it works great.\nI created this because I found that I was inputting the same commands and\ncreating the same files over and over again every time I wanted to install\na fresh copy of Ubuntu.\n***Use this script at your own risk***"
read -p "Press [Enter] to continue:" answer
clear

#Run sudo apt-get update
sudo apt-get update
clear

#Ask Arch type
correct=false
while [ "$correct" = "false" ];
	do
		read -p "32 or 64 bit installation? 32/64 :" arch
		if [ "$arch" = 32 ]; then
			correct=true
		elif [ "$arch" = 64 ]; then
			correct=true
		else
			echo "Please type either 32 or 64"
		fi
	done
clear

#Load modules for C710
read -p "1. Would you like to install touchpad modules? y/n :" answer
if [ "$answer" = y ]; then
	cat << 'EOF' | sudo tee -a /etc/modules 
i2c_i801
i2c_dev
chromeos_laptop
cyapa
EOF
	
	clear
	echo "Touchpad modules installed"
else
	echo "Not installing touchpad modules"
fi
read -p "Press [Enter] to continue:" answer
clear

#Configue synaptics for better touchpad; will fix grounding issues on battery
read -p "2. Would you like to configure the touchpad settings for better control? y/n :" answer
if [ "$answer" = y ]; then
	echo "Configuring touchpad at /usr/share/X11/xorg.conf.d/50-synaptics.conf. Backup will be saved."
	read -p "Press [Enter] to continue:" answer
	clear
	sed -i.bak '18i Option "VertHysteresis" "10"' /usr/share/X11/xorg.conf.d/50-synaptics.conf
	sed -i '18i Option "HorizHysteresis" "10"' /usr/share/X11/xorg.conf.d/50-synaptics.conf
	sed -i '18i Option "FingerLow" "1"' /usr/share/X11/xorg.conf.d/50-synaptics.conf
	sed -i '18i Option "FingerHigh" "5"' /usr/share/X11/xorg.conf.d/50-synaptics.conf
	echo "Configuration saved"
else
	echo "Touchpad not configured"
fi
read -p "Press [Enter] to continue:" answer
clear

#Configure CrOs flashrom
read -p "3. Would you like to install nessecary programs for flashrom? y/n :" answer
if [ "$answer" = y ]; then
	echo "Installing flashrom dependecies..."
	sudo apt-get install libftdi-dev libfdt-dev
		if [ "$arch" = 32 ]; then
			sudo ln -s /usr/lib/i386-linux-gnu/libftdi.so /usr/lib/i386-linux-gnu/libftdi1.so.2
		elif [ "$arch" = 64 ]; then
			sudo ln -s /usr/lib/x86_64-linux-gnu/libftdi.so /usr/lib/x86_64-linux-gnu/libftdi1.so.2
		else
			echo "Flashrom not configured"
		fi
else
	echo "Not installed"
fi
read -p "Press [Enter] to continue:" answer
clear

#Enable Hibernation
read -p "4. Would you like to enable hibernation (Swap must be larger than ram!)? y/n :" answer
if [ "$answer" = y ]; then
	#Enable hibernation
	cat << 'EOF' | sudo tee /etc/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla
[Re-enable hibernate by default in upower]
Identity=unix-user:*
Action=org.freedesktop.upower.hibernate
ResultActive=yes
[Re-enable hibernate by default in logind]
Identity=unix-user:*
Action=org.freedesktop.login1.hibernate
ResultActive=yes
EOF
	
	#Unload cyapa so that the touchpad works on resume from hibernation
	cat << 'EOF' | sudo tee /etc/pm/config.d/unload_modules
SUSPEND_MODULES="cyapa"
EOF
	cat << 'EOF' | sudo tee /etc/pm/config.d/00sleep_module
SUSPEND_MODULES="cyapa"
EOF

	clear
	echo "Hibernation enabled"
else
	echo "Hibernation not enabled"
fi
read -p "Press [Enter] to continue:" answer
clear

#Configure Intel-Pstate
read -p "5. Would you like to enable Intel-Pstate? y/n :" answer
if [ "$answer" = y ]; then
	echo "Enabling Intel-Pstate. A backup of your current grub configuration will be saved with .bak extension"
	read -p "Press [Enter] to continue:" answer
	sudo sed -i.bak s/splash/"splash intel_pstate=enable"/ /etc/default/grub
	sudo update-grub
	sudo apt-get install cpufrequtils
	
	read -p "Would you like to set the governor to powersave (this is recommended)? The default is performance. y/n :" answer
	if [ "$answer" = y ]; then
		echo "Setting governor to powersave"
		sudo sed -i 's/^GOVERNOR=.*/GOVERNOR="powersave"/' /etc/init.d/cpufrequtils
	else
		echo "Setting governor to performance"
	fi
else
	echo "Intel-Pstate not enabled"
fi
read -p "Press [Enter] to continue:" answer
clear

#Install thermald and/or tlp
read -p "6. Would you like to enable install thermald? y/n :" answer
if [ "$answer" = y ]; then
	echo "Installing thermald"
	sudo apt-get install thermald
else
	echo "thermald not installed"
fi
read -p "Press [Enter] to continue:" answer
clear

read -p "7. Would you like to enable install tlp? y/n :" answer
if [ "$answer" = y ]; then
	echo "Installing tlp"
	sudo add-apt-repository ppa:linrunner/tlp
	sudo apt-get update
	sudo apt-get install tlp tlp-rdw
	sudo tlp start
else
	echo "tlp not installed"
fi
read -p "Press [Enter] to continue:" answer
clear

#Configure keyboard shortcuts
read -p "8. Would you like to configure keyboard shortcuts such wifi, brightness, and volume? (manual configuration required) y/n :" answer
if [ "$answer" = y ]; then
	sudo apt-get install xbacklight
	clear
	echo -e "For brightness control:\n\n1.Go to System Settings > Keyboard > Shortcuts > Custom Shortcuts and add (+ icon):\n\n2. Name:Brightness Down\nCommand: /usr/bin/xbacklight -dec 5\n\n3. Name:Brightness Up\nCommand: /usr/bin/xbacklight -inc 5\n\n4.Assign shortcuts to keys (ie F6 F7)."
	read -p "Press [Enter] to continue:" answer
	clear
	echo -e "For sound control:\n\n1.Go to System Settings > Keyboard > Shortcuts > Sound and Media.\n\n2. Change the shortcuts for Volume Mute, Volume Up, Volume Down."
	read -p "Press [Enter] to continue:" answer
	clear
	cat << 'EOF' | sudo tee /bin/wifitoggle
#!/bin/bash
if [ $(nmcli nm wifi | grep "disabled" | wc -l) -eq 1 ] ; then
nmcli nm wifi on
else
nmcli nm wifi off 
fi
EOF
	clear
	sudo chmod +x /bin/wifitoggle
	echo -e "For wifi toggle:\n\n1.Go to System Settings > Keyboard > Shortcuts > Custom Shortcuts and add (+ icon):\n\n2. Name:Wifitoggle\nCommand: wifitoggle\n\n3. Assign shortcut to a key (ie Ctrl+F11)"
	read -p "Press [Enter] to continue:" answer
	clear
	echo "Keyboard configured"
else
	echo "Keyboard not configured"
fi
read -p "Press [Enter] to continue:" answer
clear
	
#Install programs
read -p "9. Would you like to install htop/restricted-extras/powertop/system monitor/synaptic? y/n :" answer
if [ "$answer" = y ]; then
	sudo apt-get install htop ubuntu-restricted-extras powertop indicator-multiload synaptic
	echo "Programs installed"
else
	echo "Programs not installed"
fi
read -p "Press [Enter] to continue:" answer
clear

#Download and install Chrome Browser
read -p "10. Download and install Chrome Browser? y/n :" answer
if [ "$answer" = y ]; then
	cd ~/Downloads
	if [ "$arch" = 64 ]; then
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		sudo dpkg -i google-chrome-stable_current_amd64.deb
		sudo apt-get install -f
	elif [ "$arch" = 32 ]; then
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
		sudo dpkg -i google-chrome-stable_current_i386.deb
		sudo apt-get install -f
	else
		echo "Incorrect arch type"
	fi
	echo "Chrome installed"
else
	echo "Chrome not installed"
fi
read -p "Press [Enter] to continue:" answer
clear

#Download and install Alex Murray Indicator Sensors
read -p "11. Download and install indicator sensors? y/n :" answer
if [ "$answer" = y ]; then
	cd ~/Downloads
	if [ "$arch" = 64 ]; then
		wget https://launchpad.net/~alexmurray/+archive/ubuntu/indicator-sensors/+build/5285672/+files/indicator-sensors_0.7-2_amd64.deb
		sudo dpkg -i indicator-sensors_0.7-2_amd64.deb
		sudo apt-get install -f
	elif [ "$arch" = 32 ]; then
		wget https://launchpad.net/~alexmurray/+archive/ubuntu/indicator-sensors/+build/5285673/+files/indicator-sensors_0.7-2_i386.deb
		sudo dpkg -i indicator-sensors_0.7-2_i386.deb
		sudo apt-get install -f
	else
		echo "Incorrect arch type"
	fi
	echo "Indicator sensors installed"
else
	echo "Indicator sensors not install"
fi
read -p "Press [Enter] to continue:" answer
clear

#Install Oracle Java 7
read -p "12. Install Oracle Java 7? y/n :" answer
if [ "$answer" = y ]; then
	sudo add-apt-repository ppa:webupd8team/java
	sudo apt-get update
	sudo apt-get install oracle-java7-installer
	echo "Java installed"
else
	echo "Java not installed"
fi
read -p "Press [Enter] to continue:" answer
clear

#Install My Weather Indicator	
read -p "13. Install My Weather Indicator? y/n:" answer
if [ "$answer" = y ]; then
	sudo add-apt-repository ppa:atareao/atareao
	sudo apt-get update
	sudo apt-get install my-weather-indicator
	echo "Weather indicator installed"
else
	echo "Weather Indicator not installed"
fi
read -p "Press [Enter] to continue:" answer
clear

#Install Playonlinux
read -p "14. Would you like to install PlayOnLinux and Wine? y/n :" answer
if [ "$answer" = y ]; then
	wget -q "http://deb.playonlinux.com/public.gpg" -O- | sudo apt-key add -
	sudo wget http://deb.playonlinux.com/playonlinux_trusty.list -O /etc/apt/sources.list.d/playonlinux.list
	sudo apt-get update
	sudo apt-get install playonlinux wine:i386
	echo "PlayOnLinux installed"
else
	echo "PlayOnLinux not installed"
fi
read -p "Press [Enter] to continue:" answer
clear

#Install Intel Graphics
echo -e "The latest drivers will cause dkms i915 taint errors on boot but everything\nappears to work correctly"
read -p "15. Would you like to install Intel Graphics Drivers? y/n :" answer
if [ "$answer" = y ]; then
	echo "Make sure you do not reboot after the installation finishes"
	read -p "Press [Enter] to continue:" answer
	cd ~/Downloads
	wget --no-check-certificate https://download.01.org/gfx/RPM-GPG-KEY-ilg -O - | \
	sudo apt-key add -
	wget --no-check-certificate https://download.01.org/gfx/RPM-GPG-KEY-ilg-2 -O - | \
	sudo apt-key add -
	if [ "$arch" = 32 ]; then
		wget https://download.01.org/gfx/ubuntu/14.04/main/pool/main/i/intel-linux-graphics-installer/intel-linux-graphics-installer_1.0.6-0intel1_i386.deb
		sudo dpkg -i intel-linux-graphics-installer_1.0.6-0intel1_i386.deb
		sudo apt-get install -f
		intel-linux-graphics-installer		
	elif [ "$arch" = 64 ]; then
		wget https://download.01.org/gfx/ubuntu/14.04/main/pool/main/i/intel-linux-graphics-installer/intel-linux-graphics-installer_1.0.6-0intel1_amd64.deb
		sudo dpkg -i intel-linux-graphics-installer_1.0.6-0intel1_amd64.deb
		sudo apt-get install -f
		intel-linux-graphics-installer	
	else
		echo "Intel Graphics Drivers Not Installed"
	fi
else
	echo "Intel Graphics Drivers Not Installed"
fi
read -p "Press [Enter] to continue:" answer
clear

#Configure system for SSD
read -p "16. Do you have a solid state drive and would you like to configure the system for it? y/n :" answer
if [ "$answer" = y ]; then
	echo "Making changes to fstab and creating backup."
	read -p "Press [Enter] to continue:" answer
	sudo sed -i.bak 's|^\S*\s\+/\s\+\S*\s\+|&noatime,nodiratime,|' /etc/fstab
	echo "Creating daily trim cron job. This will create logs at /var/log/trim.log"
	read -p "Press [Enter] to continue:" answer
	cat << 'EOF' | sudo tee /etc/cron.daily/trim
#!/bin/sh
LOG=/var/log/trim.log
echo "*** $(date -R) ***" >> $LOG
fstrim -v / >> $LOG
fstrim -v /home >> $LOG
EOF

	clear
	echo "SSD configured"
else
	echo "SSD not configured"
fi
read -p "Press [Enter] to continue:" answer
clear

#Install VirtualBox
read -p "17. Would you like to install VirtualBox? y/n :" answer
if [ "$answer" = y ]; then
	sudo apt-get install virtualbox
	echo "Virtualbox installed"
else
	echo "Virtualbox not installed"
fi
read -p "Press [Enter] to continue:" answer
clear

#Install XBMC
read -p "18. Would you like to install XBMC/KODI? y/n :" answer
if [ "$answer" = y ]; then
	sudo apt-get install xbmc
	echo "XBMC/KODI installed"
else
	echo "XBMC/KODI not installed"
fi
read -p "Press [Enter] to continue:" answer
clear

#Install Pipelight
read -p "19. Would you like to install Silverlight/Pipelight? y/n :" answer
if [ "$answer" = y ]; then
	sudo add-apt-repository ppa:pipelight/stable
	sudo apt-get update
	sudo apt-get install --install-recommends pipelight-multi
	sudo pipelight-plugin --update
	sudo pipelight-plugin --enable silverlight
	echo "Pipelight is installed and silverlight is enabled"
else
	echo "Silverlight/Pipelight not installed"
fi
read -p "Press [Enter] to continue:" answer
clear

#Install Timeshift
read -p "21. Would you like to install Timeshift? y/n :" answer
if [ "$answer" = y ]; then
	sudo apt-add-repository -y ppa:teejee2008/ppa
	sudo apt-get update
	sudo apt-get install timeshift
	echo "Timeshift installed"
else
	echo "Timeshift not installed"
fi
read -p "Press [Enter] to continue:" answer
clear

#Install Dropbox
read -p "22. Would you like to install dropbox? y/n :" answer
if [ "$answer" = y ]; then
	cd ~/
	if [ "$arch" = 32 ]; then
		wget -O dropbox.tar.gz "http://www.dropbox.com/download/?plat=lnx.x86"
		tar -xvzf dropbox.tar.gz
		~/.dropbox-dist/dropboxd
		echo "Dropbox installed"
	elif [ "$arch" = 64 ]; then
		wget -O dropbox.tar.gz "http://www.dropbox.com/download/?plat=lnx.x86_64"
		tar -xvzf dropbox.tar.gz
		~/.dropbox-dist/dropboxd
		echo "Dropbox installed"
	else
		echo "Incorrect arch type"
	fi
else
	echo "Dropbox not installed"
fi
read -p "Press [Enter] to continue:" answer
clear

#Upgrade Ubuntu
read -p "Would you like to upgrade all of the packages for Ubuntu? y/n :" answer
if [ "$answer" = y ]; then
	sudo apt-get update
	sudo apt-get dist-upgrade
	echo "Packages upgraded"
else
	echo "Packages not upgraded"
fi
read -p "Press [Enter] to continue:" answer
clear
		
#Reboot
read -p "You want to reboot now? y/n :" answer
if [ "$answer" = y ]; then
	sudo reboot
else
	echo "Script Finished"
	exit
fi

