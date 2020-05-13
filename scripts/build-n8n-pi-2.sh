#!/bin/bash
echo "Script starting. Please wait..."

PROGNAME=$(basename $0)

error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
    echo "You can rerun this script by using the command:"
    echo "wget -O - https://raw.githubusercontent.com/TephlonDude/n8n-pi/master/scripts/build-n8n-pi-1.sh | bash"
	exit 1
}

SUDO=''

if [[ $EUID -ne 0 ]]; then
    SUDO='sudo'
fi

# Checking for internet access
ping -c 3 raw.githubusercontent.com >/dev/null 2>&1 || error_exit "$LINENO: Unable to access the internet. Script exiting"

message='This script is designed to build a new n8n-pi from a base Raspbian Lite installation.\n\nThis is the second of two scripts that need to be run.\n\nIt will perform the following actions:\n    1. Clean up from previous script\n    2. Delete the pi user\n    3. Install NodeJS\n    4. Install n8n\n    5. Install & Configure PM2\n    6. Update MOTD\n    7. Reboot'
whiptail --backtitle "n8n-pi Installer" --title "n8n-pi Installer Part 2" --msgbox "$message"  18 78

if (whiptail --backtitle "n8n-pi Installer" --title "Continue with install?" --yesno "Do you wish to continue with the installation?" 8 78); then

    # Cache sudo password so that it can be used with other commends if necessary
    clear
    echo "Enter your sudo password so that we can use it when necessary during the installation. If you did not write it down, it should be n8n=gr8!"
    sudo echo -n || error_exit "$LINENO: Unable to successfully capture sudo password"

    # Clean up the temporary changes to .bashrc that allowed this script to autorun
    message=$'\U2192 Previous script cleanup\n  Delete pi user\n  Install NodeJS\n  Install n8n\n  Install & Configure PM2\n  Update MOTD\n  Reboot'
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 11 34 0
    mv ~/.bashrc ~/.bashrc-temp || error_exit "$LINENO: Unable to rename temp .bashrc file"
    mv ~/.bashrc-org ~/.bashrc || error_exit "$LINENO: Unable to rename original .bashrc file"
    rm -f ~/.bashrc-temp || error_exit "$LINENO: Unable to delete temp .bashrc file"

    # Delete the pi user and remove the home folder
    message=$'  Previous script cleanup\n\U2192 Delete pi user\n  Install NodeJS\n  Install n8n\n  Install & Configure PM2\n  Update MOTD\n  Reboot'
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 11 34 0
    $SUDO killall -u pi || error_exit "$LINENO: Unable to stop all processes owned by the pi user"
    $SUDO deluser --remove-home -f pi || error_exit "$LINENO: Unable to delete the pi user and/or remove the home directory"

    # Install NodeJS
    NODEVER=$(whiptail --backtitle "n8n-pi Installer" --title "Select NodeJS Version" --radiolist \
        "Select the version of NodeJS you would like to install:" 20 78 4 \
        "10.x" "Node.js v10.x" OFF \
        "12.x" "Node.js v12.x" ON \
        "13.x" "Node.js v13.x" OFF \
        "14.x" "Node.js v14.x" OFF \
        3>&1 1>&2 2>&3)
    # DEBURL="https://deb.nodesource.com/setup_${NODEVER}"
    message=$'  Previous script cleanup\n  Delete pi user\n\U2192  Install NodeJS\n  Install n8n\n  Install & Configure PM2\n  Update MOTD\n  Reboot'
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 11 34 0
    curl -sL https://deb.nodesource.com/setup_${NODEVER} | sudo -E bash - || error_exit "$LINENO: Unable to update NodeJs source list"
    $SUDO apt install -y nodejs || error_exit "$LINENO: Unable to install NodeJS"

    # Install n8n
    message=$'  Previous script cleanup\n  Delete pi user\n   Install NodeJS\n\U2192 Install n8n\n  Install & Configure PM2\n  Update MOTD\n  Reboot'
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 11 34 0
    cd ~ || error_exit "$LINENO: Unable to change working directory to home directory"
    # $SUDO chown -R n8n:n8n /usr/lib/node_modules || error_exit "$LINENO: Unable to change ownership of the /usr/lib/node_modules folder to user n8n"
    mkdir ~/.nodejs_global || error_exit "$LINENO: Unable to create ~/.nodejs_global"
    npm config set prefix ~/.nodejs_global || error_exit "$LINENO: Unable to set the npm prefix to ~/.nodejs_global"
    echo 'export PATH=~/.nodejs_global/bin:$PATH' | tee --append ~/.profile >/dev/null || error_exit "$LINENO: Unable to update ~/.profile to update PATH variable"
    source ~/.profile || error_exit "$LINENO: Unable to reload ~/.profile "
    npm install n8n -g || error_exit "$LINENO: Unable to install n8n"

    # Install & Configure PM2
    message=$'  Previous script cleanup\n  Delete pi user\n   Install NodeJS\n  Install n8n\n\U2192 Install & Configure PM2\n  Update MOTD\n  Reboot'
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 11 34 0
    cd ~ || error_exit "$LINENO: Unable to move the the home directory"
    npm install pm2@latest -g || error_exit "$LINENO: Unable to install PM2"
    if (whiptail  --backtitle "n8n-pi Installer" --title "Tunnel?" --yesno "Do you wish to start n8n with the tunnel option?" 8 40); then
        pm2 start n8n --tunnel || error_exit "$LINENO: Unable to start n8n with tunnel option using PM2"
    else
        pm2 start n8n || error_exit "$LINENO: Unable to start n8n using PM2"
    fi

    # Install Updated MOTD
    message=$'  Previous script cleanup\n  Delete pi user\n   Install NodeJS\n  Install n8n\n  Install & Configure PM2\n\U2192  Update MOTD\n  Reboot'
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 11 34 0
    $SUDO wget -O /etc/update-motd.d/11-n8n https://raw.githubusercontent.com/TephlonDude/n8n-pi/master/motd/11-n8n || error_exit "$LINENO: Unable to retrieve 11-n8n file"
    $SUDO chmod 755 /etc/update-motd.d/11-n8n || error_exit "$LINENO: Unable to set 11-n8n permissions"

    # Reboot
    IPADDR=$( ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
    message=$'The final phase of the installation has finished. We must now reboot the system in order for some changes to take effect.\n\nWhen the system comes back online, you should be able to access the n8n WebUI from https://${IPADDR}:5678.'
    whiptail --backtitle "n8n-pi Installer" --title "Time to Reboot" --msgbox "$message"  17 78
    $SUDO reboot || error_exit "$LINENO: Unable to reboot"


else 
    error_exit "$LINENO: Installation cancelled"
fi
