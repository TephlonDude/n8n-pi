#!/bin/bash
echo "Script starting. Please wait..."

PROGNAME=$(basename $0)

error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
    echo "You can rerun this script by using the command:"
    echo $(dirname $0)/$(basename $0)
	exit 1
}

SUDO=''

if [[ $EUID -ne 0 ]]; then
    SUDO='sudo'
fi

# Checking for internet access
ping -c 3 raw.githubusercontent.com >/dev/null 2>&1 || error_exit "$LINENO: Unable to access the internet. Script exiting"

message='This script is designed to build a new n8n-pi from a base Raspbian Lite installation.\n\nThis is the second of two scripts that need to be run.\n\nIt will perform the following actions:\n    1. Clean up from previous script\n    2. Delete the pi user\n    3. Install NodeJS\n    4. Install n8n\n    5. Update MOTD\n    6. Reboot'
whiptail --backtitle "n8n-pi Installer" --title "n8n-pi Installer Part 2" --msgbox "$message"  18 78

if (whiptail --backtitle "n8n-pi Installer" --title "Continue with install?" --yesno "Do you wish to continue with the installation?" 8 78); then

    # Cache sudo password so that it can be used with other commends if necessary
    clear
    echo "Enter your sudo password so that we can use it when necessary during the installation. If you did not write it down, it should be n8n=gr8!"
    sudo echo -n || error_exit "$LINENO: Unable to successfully capture sudo password"

    # Clean up the temporary changes to .bashrc that allowed this script to autorun
    message=$'\U2192 Previous script cleanup\n  Delete pi user\n  Install NodeJS\n  Install n8n\n  Update MOTD\n  Reboot'
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 11 34 0
    mv ~/.bashrc ~/.bashrc-temp || error_exit "$LINENO: Unable to rename temp .bashrc file"
    mv ~/.bashrc-org ~/.bashrc || error_exit "$LINENO: Unable to rename original .bashrc file"
    rm -f ~/.bashrc-temp || error_exit "$LINENO: Unable to delete temp .bashrc file"

    # Delete the pi user and remove the home folder
    message=$'  Previous script cleanup\n\U2192 Delete pi user\n  Install NodeJS\n  Install n8n\n  Update MOTD\n  Reboot'
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
    message=$'  Previous script cleanup\n  Delete pi user\n\U2192  Install NodeJS\n  Install n8n\n  Update MOTD\n  Reboot'
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 11 34 0
    curl -sL https://deb.nodesource.com/setup_${NODEVER} | sudo -E bash - || error_exit "$LINENO: Unable to update NodeJs source list"
    $SUDO apt install -y nodejs || error_exit "$LINENO: Unable to install NodeJS"

    # Install n8n
    message=$'  Previous script cleanup\n  Delete pi user\n   Install NodeJS\n\U2192 Install n8n\n  Update MOTD\n  Reboot'
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 11 34 0
    cd ~ || error_exit "$LINENO: Unable to change working directory to home directory"
    # $SUDO chown -R n8n:n8n /usr/lib/node_modules || error_exit "$LINENO: Unable to change ownership of the /usr/lib/node_modules folder to user n8n"
    mkdir ~/.nodejs_global || error_exit "$LINENO: Unable to create ~/.nodejs_global"
    npm config set prefix ~/.nodejs_global || error_exit "$LINENO: Unable to set the npm prefix to ~/.nodejs_global"
    echo 'export PATH=~/.nodejs_global/bin:$PATH' | tee --append ~/.profile >/dev/null || error_exit "$LINENO: Unable to update ~/.profile to update PATH variable"
    source ~/.profile || error_exit "$LINENO: Unable to reload ~/.profile "
    npm install n8n -g || error_exit "$LINENO: Unable to install n8n"

else 
    error_exit "$LINENO: Installation cancelled"
fi
