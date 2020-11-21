#!/bin/bash
logfile=~/n8n-install.log

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
    echo $1...

}

# Runs commands with "sudo" if the user running the script is not root
SUDO=''
if [[ $EUID -ne 0 ]]; then
    SUDO='sudo'
fi

clear

message='This script is designed to install a fresh n8n installation along with all the little nit picky things that sometimes are a challenge. It is designed for Debian based linux installs. This script will:\n    1. Install build dependencies\n    2. Add NodeJS 12 Soource List\n    3. Install NodeJS 12\n    4. Install n8n\n    5. Install & Configure PM2\n'
whiptail --backtitle "n8n Easy Installer" --title "n8n-pi Easy Installer" --msgbox "$message"  18 78

if (whiptail --backtitle "n8n Easy Installer" --title "Continue with install?" --yesno "Do you wish to continue with the installation?" 8 78); then

    # 1. Install dependencies
    log_heading "Installing dependencies"
    $SUDO apt update &>>$logfile || error_exit "$LINENO: Unable to update apt"
    $SUDO apt install build-essential -y &>>$logfile || error_exit "$LINENO: Unable to install dependencies"

    # 2. Add NodeJS 12 Source List
    log_heading "Add NodeJS 12 Source List"
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - &>>$logfile || error_exit "$LINENO: Unable to update NodeJs source list"

    # 3. Install Node JS
    log_heading "Installing dependencies"
    $SUDO apt install -y nodejs &>>$logfile || error_exit "$LINENO: Unable to install NodeJS"

    # 4. Install n8n
    log_heading "Installing n8n"
    cd ~ &>>$logfile || error_exit "$LINENO: Unable to change working directory to home directory"
    mkdir ~/.nodejs_global &>>$logfile || error_exit "$LINENO: Unable to create ~/.nodejs_global"
    npm config set prefix ~/.nodejs_global &>>$logfile || error_exit "$LINENO: Unable to set the npm prefix to ~/.nodejs_global"
    echo 'export PATH=~/.nodejs_global/bin:$PATH' | tee --append ~/.profile &>>$logfile || error_exit "$LINENO: Unable to update ~/.profile to update PATH variable"
    source ~/.profile &>>$logfile || error_exit "$LINENO: Unable to reload ~/.profile "
    npm install n8n -g &>>$logfile || error_exit "$LINENO: Unable to install n8n"

    # 5. Install & Configure PM2
    log_heading "Install & Configure PM2"
    cd ~ &>>$logfile || error_exit "$LINENO: Unable to move the the home directory"
    npm install pm2@latest -g &>>$logfile || error_exit "$LINENO: Unable to install PM2"
    pm2 start n8n &>>$logfile || error_exit "$LINENO: Unable to start n8n using PM2"

    # Install Complete (The second URL that is used needs to display the hostname dynamically)
    IPADDR=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
    message="The final phase of the installation has finished. You should be able to access the n8n WebUI from http://${IPADDR}:5678"
    whiptail --backtitle "n8n Easy Installer" --title "Install Complete" --msgbox "$message"  17 78
    clear

else 
    error_exit "$LINENO: Installation cancelled"
fi