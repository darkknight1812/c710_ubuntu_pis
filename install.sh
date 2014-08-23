#!/bin/bash
#Acer C710 Ubuntu Post-Installation Script

#Run sudo apt-get update
sudo apt-get update

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
			echo "Please type either 32 or 64."
		fi
	done
#Load modules for C710
read -p "Would you like to install touchpad modules? y/n :" answer
if [ "$answer" = y ]; then
	echo "Installing touchpad modules..."
	cat << 'EOF' | sudo tee -a /etc/modules 
i2c_i801
i2c_dev
chromeos_laptop
cyapa
EOF
else
	echo "Not installing touchpad modules"
fi

#Configue synaptics for better touchpad; will fix grounding issues on battery
read -p "Would you like to configure the touchpad settings for better control? y/n :" answer
if [ "$answer" = y ]; then
	echo "Configuring touchpad at /usr/share/X11/xorg.conf.d/50-synaptics.conf. Backup will be saved."
	sed -i.bak '18i Option "VertHysteresis" "10"' /usr/share/X11/xorg.conf.d/50-synaptics.conf
	sed -i '18i Option "HorizHysteresis" "10"' /usr/share/X11/xorg.conf.d/50-synaptics.conf
	sed -i '18i Option "FingerLow" "1"' /usr/share/X11/xorg.conf.d/50-synaptics.conf
	sed -i '18i Option "FingerHigh" "5"' /usr/share/X11/xorg.conf.d/50-synaptics.conf
else
	echo "Touchpad not configured"
fi

#Configure CrOs flashrom
read -p "Would you like to install nessecary programs for flashrom? y/n :" answer
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
	echo "Not installing."
fi

#Enable Hibernation
read -p "Would you like to enable hibernation? y/n :" answer
if [ "$answer" = y ]; then
	echo "Enabling hibernation"
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
else
	echo "Hibernation not enabled"
fi

#Configure Intel-Pstate
read -p "Would you like to enable Intel-Pstate? y/n :" answer
if [ "$answer" = y ]; then
	echo "Enabling Intel-Pstate. A backup of your current grub configuration will be saved with .bak extension"
	sudo sed -i.bak s/splash/"splash intel_pstate=enable"/ /etc/default/grub
	sudo update-grub
	sudo apt-get install cpufrequtils
	
	read -p "Would you like to set the governor to powersaving (this is recommended)? The default is performance. y/n :" answer
	if [ "$answer" = y ]; then
		echo "Setting governor to powersave"
		sudo sed -i 's/^GOVERNOR=.*/GOVERNOR="powersave"/' /etc/init.d/cpufrequtils
	else
		echo "Setting governor to performance"
	fi
else
	echo "Intel-Pstate not enabled"
fi

#Install thermald and/or tlp
read -p "Would you like to enable install thermald? y/n :" answer
if [ "$answer" = y ]; then
	echo "Installing thermald..."
	sudo apt-get install thermald
else
	echo "thermald not installed"
fi

read -p "Would you like to enable install tlp? y/n :" answer
if [ "$answer" = y ]; then
	echo "Installing tlp"
	sudo add-apt-repository ppa:linrunner/tlp
	sudo apt-get update
	sudo apt-get install tlp tlp-rdw
	sudo tlp start
else
	echo "tlp not installed"
fi
	
#Install programs
read -p "Would you like to install xbacklight/htop/restricted-extras/powertop? y/n :" answer
if [ "$answer" = y ]; then
	sudo apt-get install xbacklight htop ubuntu-restricted-extras powertop
else
	echo "Programs not installed"
fi

#Download other programs from the web
read -p "Would you like to install Chrome Browser and/or indicator sensors (Shows cpu temp)? y/n :" answer
if [ "$answer" = y ]; then
	cd ~/Downloads
	read -p "Download and install Chrome Browser? y/n :" answer
	if [ "$answer" = y ]; then
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		sudo dpkg -i google-chrome-stable_current_amd64.deb
		#Chrome install will likely fail so force install for dependicies
		sudo apt-get install -f
	else
		echo "Chrome not installed"
	fi

	read -p "Download and install indicator sensors? y/n :" answer
	if [ "$answer" = y ]; then
		wget https://launchpad.net/~alexmurray/+archive/ubuntu/indicator-sensors/+build/5285672/+files/indicator-sensors_0.7-2_amd64.deb
		sudo dpkg -i indicator-sensors_0.7-2_amd64.deb
	else
		echo "Indicator sensors not install"
	fi
else
	echo "Programs not installed"
fi

#Install some repos and install their programs
read -p "Would you like to install Oracle Java 7 and/or My Weather Indicator? y/n :" answer
if [ "$answer" = y ]; then
	read -p "Install Oracle Java 7? y/n :" answer
	if [ "$answer" = y ]; then
		sudo add-apt-repository ppa:webupd8team/java
		sudo apt-get update
		sudo apt-get install oracle-java7-installer
	else
		echo "Java not installed"
	fi
	
	read -p "Install My Weather Indicator? y/n:" answer
	if [ "$answer" = y ]; then
		sudo add-apt-repository ppa:atareao/atareao
		sudo apt-get update
		sudo apt-get install my-weather-indicator
	else
		echo "Weather Indicator not installed"
	fi
else
	echo "Programs not installed"
fi

#Install Playonlinux
read -p "Would you like to install PlayOnLinux and Wine? y/n :" answer
if [ "$answer" = y ]; then
	wget -q "http://deb.playonlinux.com/public.gpg" -O- | sudo apt-key add -
	sudo wget http://deb.playonlinux.com/playonlinux_trusty.list -O /etc/apt/sources.list.d/playonlinux.list
	sudo apt-get update
	sudo apt-get install playonlinux wine:i386
else
	echo "PlayOnLinux not install"
fi

#Upgrade Ubuntu
read -p "Would you like to upgrade all of the packages for Ubuntu? y/n :" answer
if [ "$answer" = y ]; then
	sudo apt-get update
	sudo apt-get upgrade
else
	echo "Packages not upgraded"
fi

#Install Intel Graphics
read -p "Would you like to install Intel Graphics Drivers? y/n :"
if [ "$answer" = y ]; then
	cd ~/Downloads
	wget --no-check-certificate https://download.01.org/gfx/RPM-GPG-KEY-ilg -O - | \
	sudo apt-key add -
	wget --no-check-certificate https://download.01.org/gfx/RPM-GPG-KEY-ilg-2 -O - | \
	sudo apt-key add -
	if [ "$arch" = 32 ]; then
		wget https://download.01.org/gfx/ubuntu/14.04/main/pool/main/i/intel-linux-graphics-installer/intel-linux-graphics-installer_1.0.6-0intel1_i386.deb
		sudo dpkg -i intel-linux-graphics-installer_1.0.6-0intel1_i386.deb
		intel-linux-graphics-installer		
	elif [ "$arch" = 64 ]; then
		wget https://download.01.org/gfx/ubuntu/14.04/main/pool/main/i/intel-linux-graphics-installer/intel-linux-graphics-installer_1.0.6-0intel1_amd64.deb
		sudo dpkg -i intel-linux-graphics-installer_1.0.6-0intel1_amd64.deb
		intel-linux-graphics-installer	
	else
		echo "Intel Graphics Drivers Not Installed"
	fi
else
	echo "Intel Graphics Drivers Not Installed"
fi

#Configure system for SSD
read -p "Do you have a solid state drive and would you like to configure the system for it? y/n :" answer
if [ "$answer" = y ]; then
	echo "Making changes to fstab and creating backup."
	sudo sed -i.bak 's|^\S*\s\+/\s\+\S*\s\+|&noatime,nodiratime,|' /etc/fstab
	echo "Creating daily trim cron job. This will create logs at /var/log/trim.log"
	cat << 'EOF' | sudo tee /etc/cron.daily/trim
#!/bin/sh
LOG=/var/log/trim.log
echo "*** $(date -R) ***" >> $LOG
fstrim -v / >> $LOG
fstrim -v /home >> $LOG
EOF

else
	echo "SSD not configured"
fi

#Install VirtualBox
read -p "Would you like to install VirtualBox? y/n :" answer
if [ "$answer" = y ]; then
	sudo apt-get install virtualbox
else
	echo "Virtualbox not installed"
fi

#Install XBMC
read -p "Would you like to install XBMC/KODI? y/n :" answer
if [ "$answer" = y ]; then
	sudo apt-get install xbmc
else
	echo "XBMC/KODI not installed"
fi

#Install Pipelight
read -p "Would you like to install Silverlight/Pipelight? y/n :"
if [ "$answer" = y ]; then
	sudo add-apt-repository ppa:pipelight/stable
	sudo apt-get update
	sudo apt-get install --install-recommends pipelight-multi
	sudo pipelight-plugin --update
	sudo pipelight-plugin --enable silverlight
else
	echo "Silverlight/Pipelight not installed."
fi
		
#Reboot
read -p "You want to reboot now? y/n :" answer
if [ "$answer" = y ]; then
	sudo reboot
else
	echo "Script Finished"
	exit
fi

