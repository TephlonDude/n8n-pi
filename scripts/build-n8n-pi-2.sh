#!/bin/bash
logfile=/var/log/n8n-pi.log

# Deals with errors
error_exit()
{
	echo "${1:-"Unknown Error"}" 1>&2
    echo "Last 10 entried by this script:"
    tail $logfile
    echo "Full log details are recorded in $logfile"
	exit 1
}

# Create log headings
log_heading()
{
    length=${#1}
    length=`expr $length + 8`
    printf '%*s' $length | tr ' ' '*'>>$logfile
    echo>>$logfile
    echo "*** $1 ***">>$logfile
    printf '%*s' $length | tr ' ' '*'>>$logfile
    echo>>$logfile
    echo -n $1...

}

# Runs commands with "sudo" if the user running the script is not root
SUDO=''
if [[ $EUID -ne 0 ]]; then
    SUDO='sudo'
fi

clear

message='This script is designed to build a new n8n-pi from a base Raspbian Lite installation.\n\nThis is the second of two scripts that need to be run.\n\nIt will perform the following actions:\n    1. Clean up from previous script\n    2. Delete the pi user\n    3. Install NodeJS\n    4. Install n8n\n    5. Install & Configure PM2\n    6. Update MOTD\n    7. /etc/sudoers Cleanup\n    8. Reboot'
whiptail --backtitle "n8n-pi Installer" --title "n8n-pi Installer Part 2" --msgbox "$message"  18 78

if (whiptail --backtitle "n8n-pi Installer" --title "Continue with install?" --yesno "Do you wish to continue with the installation?" 8 78); then

    # Clean up the temporary changes to .bashrc that allowed this script to autorun
    log_heading "Clean up autorun entries"
    mv ~/.bashrc ~/.bashrc-temp &>>$logfile || error_exit "$LINENO: Unable to rename temp .bashrc file"
    mv ~/.bashrc-org ~/.bashrc &>>$logfile || error_exit "$LINENO: Unable to rename original .bashrc file"
    rm -f ~/.bashrc-temp &>>$logfile || error_exit "$LINENO: Unable to delete temp .bashrc file"
    echo "done!"

    # Delete the pi user and remove the home folder
    log_heading "Delete the pi user and remove the home folder"
    $SUDO killall -q -u pi &>>$logfile
    $SUDO deluser --remove-home -f pi &>>$logfile || error_exit "$LINENO: Unable to delete the pi user and/or remove the home directory"
    echo "done!"

    # Install NodeJS
    log_heading "Install NodeJS (Please be patient, this may take a while)"
    NODEVER=$(whiptail --backtitle "n8n-pi Installer" --title "Select NodeJS Version" --radiolist \
        "Select the version of NodeJS you would like to install:" 20 78 4 \
        "10.x" "Node.js v10.x" OFF \
        "12.x" "Node.js v12.x" ON \
        "13.x" "Node.js v13.x" OFF \
        "14.x" "Node.js v14.x" OFF \
        3>&1 1>&2 2>&3)
    curl -sL https://deb.nodesource.com/setup_${NODEVER} | sudo -E bash - &>>$logfile || error_exit "$LINENO: Unable to update NodeJs source list"
    $SUDO apt install -y nodejs &>>$logfile || error_exit "$LINENO: Unable to install NodeJS"
    echo "done!"

    # Install n8n
    log_heading "Install n8n (Please be patient, this may take a while)"
    cd ~ &>>$logfile || error_exit "$LINENO: Unable to change working directory to home directory"
    mkdir ~/.nodejs_global &>>$logfile || error_exit "$LINENO: Unable to create ~/.nodejs_global"
    npm config set prefix ~/.nodejs_global &>>$logfile || error_exit "$LINENO: Unable to set the npm prefix to ~/.nodejs_global"
    echo 'export PATH=~/.nodejs_global/bin:$PATH' | tee --append ~/.profile &>>$logfile || error_exit "$LINENO: Unable to update ~/.profile to update PATH variable"
    source ~/.profile &>>$logfile || error_exit "$LINENO: Unable to reload ~/.profile "
    npm install n8n -g &>>$logfile || error_exit "$LINENO: Unable to install n8n"
    echo "done!"

    # Install & Configure PM2
    log_heading "Install & Configure PM2"
    cd ~ &>>$logfile || error_exit "$LINENO: Unable to move the the home directory"
    npm install pm2@latest -g &>>$logfile || error_exit "$LINENO: Unable to install PM2"
    if (whiptail  --backtitle "n8n-pi Installer" --title "Tunnel?" --yesno "Do you wish to start n8n with the tunnel option?" 8 40); then
        pm2 start n8n --tunnel &>>$logfile || error_exit "$LINENO: Unable to start n8n with tunnel option using PM2"
    else
        pm2 start n8n &>>$logfile || error_exit "$LINENO: Unable to start n8n using PM2"
    fi
    pm2 startup &>>$logfile
    $SUDO env PATH=$PATH:/usr/bin /home/n8n/.nodejs_global/lib/node_modules/pm2/bin/pm2 startup systemd -u n8n --hp /home/n8n &>>$logfile || error_exit "$LINENO: Unable to create PM2 autostart"
    pm2 save &>>$logfile || error_exit "$LINENO: Unable to save PM2 configuration"
    echo "done!"

    # Install Updated MOTD
    log_heading "Install Updated MOTD"
    $SUDO wget --no-cache -O /etc/update-motd.d/11-n8n https://raw.githubusercontent.com/TephlonDude/n8n-pi/master/motd/11-n8n &>>$logfile || error_exit "$LINENO: Unable to retrieve 11-n8n file"
    $SUDO chmod 755 /etc/update-motd.d/11-n8n &>>$logfile || error_exit "$LINENO: Unable to set 11-n8n permissions"
    echo "done!"

    # Change sudo security
    log_heading "Change sudo security"
    $SUDO cp -f /etc/sudoers.org /etc/sudoers &>>$logfile || error_exit "$LINENO: Unable to replace /etc/sudoers with /etc/sudoers.org"
    echo "done!"

    # Final Cleanup
    log_heading "Final cleanup"
    rm -f ~/build-n8n-pi-2.sh &>>$logfile || error_exit "$LINENO: Unable to delete ~/build-n8n-pi-2.sh"
    echo "done!"

    # Install Complete
    IPADDR=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
    message="The final phase of the installation has finished. You should be able to access the n8n WebUI from https://${IPADDR}:5678."
    whiptail --backtitle "n8n-pi Installer" --title "Install Complete" --msgbox "$message"  17 78
    clear
 
else 
    error_exit "$LINENO: Installation cancelled"
fi
