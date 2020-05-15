#!/bin/bash
logfile=/var/log/n8n-pi.log

# Deals with errors
error_exit()
{
	echo "${1:-"Unknown Error"}" 1>&2
    echo "Last 10 entried by this script:"
    tail $logfile
    echo "Full log details are recorded in $logfile"
    echo
    echo "You can rerun this script by using the command:"
    echo "wget -O - https://raw.githubusercontent.com/TephlonDude/n8n-pi/master/scripts/build-n8n-pi-1.sh | bash"
	exit 1
}

# Create log headings
log_heading()
{
    length=${#1}
    length=`expr length + 8`
    printf '%*s' $length | tr ' ' '*'>>$logfile
    echo>>$logfile
    echo "*** $1 ***">>$logfile
    printf '%*s' $length | tr ' ' '*'>>$logfile
    echo>>$logfile
    echo -n $1

}

elevate()
{
    if [[ $EUID -ne 0 ]]; then
        echo $sudo_pwd | sudo -S $1 &>>$logfile
    else
        echo $1 &>>$logfile
    fi
    return $?
}

clear

# Checking for internet access
log_heading "Checking for internet access..."
ping -c 5 raw.githubusercontent.com &>>$logfile || error_exit "$LINENO: Unable to access the internet. Script exiting"
echo "done!"

message='This script is designed to build a new n8n-pi from a base Raspbian Lite installation.\n\nThis is the second of two scripts that need to be run.\n\nIt will perform the following actions:\n    1. Clean up from previous script\n    2. Delete the pi user\n    3. Install NodeJS\n    4. Install n8n\n    5. Install & Configure PM2\n    6. Update MOTD\n    7. Reboot'
whiptail --backtitle "n8n-pi Installer" --title "n8n-pi Installer Part 2" --msgbox "$message"  18 78

if (whiptail --backtitle "n8n-pi Installer" --title "Continue with install?" --yesno "Do you wish to continue with the installation?" 8 78); then

    # Cache sudo password so that it can be used with other commends if necessary
    # clear
    # echo "Enter your sudo password so that we can use it when necessary during the installation. If you did not write it down, it should be n8n=gr8!"
    # sudo echo -n || error_exit "$LINENO: Unable to successfully capture sudo password"

    if [[ $EUID -ne 0 ]]; then
        sudo_pwd=$(whiptail --backtitle "n8n-pi Installer" --passwordbox "Please provide the SUDO password:" 8 34 n8n=gr8! --title "SUDO Password" 3>&1 1>&2 2>&3)
    fi

    # Clean up the temporary changes to .bashrc that allowed this script to autorun
    log_heading "Clean up the temporary changes to .bashrc that allowed this script to autorun..."
    mv ~/.bashrc ~/.bashrc-temp &>>$logfile || error_exit "$LINENO: Unable to rename temp .bashrc file"
    mv ~/.bashrc-org ~/.bashrc &>>$logfile || error_exit "$LINENO: Unable to rename original .bashrc file"
    rm -f ~/.bashrc-temp &>>$logfile || error_exit "$LINENO: Unable to delete temp .bashrc file"

    # Delete the pi user and remove the home folder
    message=$'  Previous script cleanup\n\U2192 Delete pi user\n  Install NodeJS\n  Install n8n\n  Install & Configure PM2\n  Update MOTD\n  Reboot'
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 11 34 17
    elevate "killall -u pi" || error_exit "$LINENO: Unable to stop all processes owned by the pi user"
    elevate "deluser --remove-home -f pi" || error_exit "$LINENO: Unable to delete the pi user and/or remove the home directory"

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
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 11 34 33
    curl -sL https://deb.nodesource.com/setup_${NODEVER} | sudo -E bash - &>>$logfile || error_exit "$LINENO: Unable to update NodeJs source list"
    elevate "apt install -y nodejs" || error_exit "$LINENO: Unable to install NodeJS"

    # Install n8n
    message=$'  Previous script cleanup\n  Delete pi user\n   Install NodeJS\n\U2192 Install n8n\n  Install & Configure PM2\n  Update MOTD\n  Reboot'
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 11 34 50
    cd ~ &>>$logfile || error_exit "$LINENO: Unable to change working directory to home directory"
    # elevate "chown -R n8n:n8n /usr/lib/node_modules || error_exit "$LINENO: Unable to change ownership of the /usr/lib/node_modules folder to user n8n"
    mkdir ~/.nodejs_global &>>$logfile || error_exit "$LINENO: Unable to create ~/.nodejs_global"
    npm config set prefix ~/.nodejs_global &>>$logfile || error_exit "$LINENO: Unable to set the npm prefix to ~/.nodejs_global"
    echo 'export PATH=~/.nodejs_global/bin:$PATH' | tee --append ~/.profile &>>$logfile || error_exit "$LINENO: Unable to update ~/.profile to update PATH variable"
    source ~/.profile &>>$logfile || error_exit "$LINENO: Unable to reload ~/.profile "
    npm install n8n -g &>>$logfile || error_exit "$LINENO: Unable to install n8n"

    # Install & Configure PM2
    message=$'  Previous script cleanup\n  Delete pi user\n   Install NodeJS\n  Install n8n\n\U2192 Install & Configure PM2\n  Update MOTD\n  Reboot'
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 11 34 67
    cd ~ &>>$logfile || error_exit "$LINENO: Unable to move the the home directory"
    npm install pm2@latest -g &>>$logfile || error_exit "$LINENO: Unable to install PM2"
    if (whiptail  --backtitle "n8n-pi Installer" --title "Tunnel?" --yesno "Do you wish to start n8n with the tunnel option?" 8 40); then
        pm2 start n8n --tunnel &>>$logfile || error_exit "$LINENO: Unable to start n8n with tunnel option using PM2"
    else
        pm2 start n8n &>>$logfile || error_exit "$LINENO: Unable to start n8n using PM2"
    fi

    # Install Updated MOTD
    message=$'  Previous script cleanup\n  Delete pi user\n   Install NodeJS\n  Install n8n\n  Install & Configure PM2\n\U2192  Update MOTD\n  Reboot'
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 11 34 83
    elevate "wget -O /etc/update-motd.d/11-n8n https://raw.githubusercontent.com/TephlonDude/n8n-pi/master/motd/11-n8n" || error_exit "$LINENO: Unable to retrieve 11-n8n file"
    elevate "chmod 755 /etc/update-motd.d/11-n8n" || error_exit "$LINENO: Unable to set 11-n8n permissions"

    # Reboot
    IPADDR=$( ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
    message=$'The final phase of the installation has finished. We must now reboot the system in order for some changes to take effect.\n\nWhen the system comes back online, you should be able to access the n8n WebUI from https://${IPADDR}:5678.'
    whiptail --backtitle "n8n-pi Installer" --title "Time to Reboot" --msgbox "$message"  17 78
    elevate "reboot" || error_exit "$LINENO: Unable to reboot"

else 
    error_exit "$LINENO: Installation cancelled"
fi
