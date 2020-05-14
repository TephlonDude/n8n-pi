#!/bin/bash
PROGNAME=$(basename $0)

# Deals with errors
error_exit()
{
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
    echo "You can rerun this script by using the command:"
    echo "wget -O - https://raw.githubusercontent.com/TephlonDude/n8n-pi/master/scripts/build-n8n-pi-1.sh | bash"
	exit 1
}

# Runs commands with "sudo" if the user running the script is not root
SUDO=''
if [[ $EUID -ne 0 ]]; then
    SUDO='sudo'
fi

clear

# Checking for internet access
echo -n "Checking for internet access..."
ping -c 5 raw.githubusercontent.com >/dev/null 2>&1 || error_exit "$LINENO: Unable to access the internet. Script exiting"
echo "done!"

# Introduction message
message=$'This script is designed to build a new n8n-pi from a base Raspbian Lite installation.\n\nThis is the first of two scripts that need to be run.\n\nIt will perform the following actions:\n    1. Update Raspian Lite to the latest software\n    2. Install dependencies\n    3. Rename the server\n    4. Adds the n8n user\n    5. Install base custom MOTD\n    6. Update hostname\n    7. Reboot'
whiptail --backtitle "n8n-pi Installer" --title "Welcome to the n8n-pi Installer" --msgbox "$message"  17 78

# Asks user for permission to continue
if (whiptail --backtitle "n8n-pi Installer" --title "Continue with install?" --yesno "Do you wish to continue with the installation?" 8 78); then

    # Updates list of packages
    echo -n "Updating package list..."
    $SUDO apt update >/dev/null 2>&1 || error_exit "$LINENO: Unable to update apt sources"
    echo "done!"

    # Upgrades packages
    echo -n "Upgrading packages..."
    whiptail --backtitle "n8n-pi Installer" --gauge "$message" 13 34 13
    $SUDO apt upgrade -y >/dev/null 2>&1 || error_exit "$LINENO: Unable to upgrade packages"
    echo "done!"

    # Installs figlet and jq needed for MOTD, build essentials for NodeJS
    echo -n "Installing dependencies..."
    $SUDO apt install figlet jq build-essential -y >/dev/null 2>&1 || error_exit "$LINENO: Unable to install dependencies"
    echo "done!"

    # Create the n8n user
    echo -n "Creating n8n user..."
    $SUDO adduser --disabled-password --gecos "" n8n >/dev/null 2>&1 || error_exit "$LINENO: Unable to create n8n user"
    $SUDO usermod -a -G sudo n8n >/dev/null 2>&1 || error_exit "$LINENO: Unable to add n8n user to sudo group"
    echo 'n8n:n8n=gr8!' | $SUDO chpasswd >/dev/null 2>&1 || error_exit "$LINENO: Unable to set n8n password"
    echo "done!"

    # Install first MOTD
    echo -n "Updating MOTD (1 of 2)..."
    $SUDO wget -O /etc/update-motd.d/10-sysinfo https://raw.githubusercontent.com/TephlonDude/n8n-pi/master/motd/10-sysinfo >/dev/null 2>&1 || error_exit "$LINENO: Unable to retrieve 10-sysinfo file"
    $SUDO chmod 755 /etc/update-motd.d/10-sysinfo >/dev/null 2>&1 || error_exit "$LINENO: Unable to set 10-sysinfo permissions"
    $SUDO rm -f /etc/update-motd.d/10-uname >/dev/null 2>&1 || error_exit "$LINENO: Unable to remove /etc/update-motd.d/10-uname"
    $SUDO truncate -s 0 /etc/motd >/dev/null 2>&1 || error_exit "$LINENO: Unable to delete the contents of /etc/motd"
    $SUDO rm -f /etc/profile.d/sshpwd.sh >/dev/null 2>&1 || error_exit "$LINENO: Unable to remove /etc/profile.d/sshpwd.sh"
    $SUDO rm -f /etc/profile.d/wifi-check.sh >/dev/null 2>&1 || error_exit "$LINENO: Unable to remove /etc/profile.d/wifi-check.sh"
    $SUDO sed -i 's/#PrintLastLog yes/PrintLastLog no/g' /etc/ssh/sshd_config >/dev/null 2>&1 || error_exit "$LINENO: Unable to disable showing last time user logged in by editing /etc/ssh/sshd_config"
    echo "done!"

    # Reset hostname
    echo -n "Setting new hostname..."
    newhostname=$(whiptail --backtitle "n8n-pi Installer" --inputbox "Please provide a new hostname:" 8 34 n8n-pi --title "New Hostname" 3>&1 1>&2 2>&3)
    echo $newhostname | $SUDO tee /etc/hostname  >/dev/null 2>&1 || error_exit "$LINENO: Unable to set new hostname in /etc/hostname"
    $SUDO sed -i 's/raspberrypi/$newhostname/g' /etc/hosts >/dev/null 2>&1 || error_exit "$LINENO: Unable to set new hostname in /etc/hosts"
    echo "done!"

    # Prepare for reboot
    echo -n "Preparing for reboot..."
    $SUDO wget -O /home/n8n/build-n8n-pi-2.sh https://raw.githubusercontent.com/TephlonDude/n8n-pi/master/scripts/build-n8n-pi-2.sh >/dev/null 2>&1 || error_exit "$LINENO: Unable to retrieve build-n8n-pi-2.sh"
    $SUDO chmod 755 /home/n8n/build-n8n-pi-2.sh >/dev/null 2>&1 || error_exit "$LINENO: Unable to set build-n8n-pi-2.sh permissions"
    $SUDO chown n8n:n8n /home/n8n/build-n8n-pi-2.sh >/dev/null 2>&1 || error_exit "$LINENO: Unable to set ownership for build-n8n-pi-2.sh to n8n user"
    $SUDO cp /home/n8n/.bashrc /home/n8n/.bashrc-org >/dev/null 2>&1 || error_exit "$LINENO: Unable to copy /home/n8n/.bashrc to /home/n8n/.bashrc-org"
    $SUDO chown n8n:n8n /home/n8n/.bashrc-org >/dev/null 2>&1 || error_exit "$LINENO: Unable to set ownership for /home/n8n/.bashrc-org"
    echo '~/build-n8n-pi-2.sh' | sudo tee --append /home/n8n/.bashrc  >/dev/null 2>&1 || error_exit "$LINENO: Unable to update /home/n8n/.bashrc to autorun build-n8n-pi-2.sh on next n8n user login"
    echo "done!"

    # Final message and instructions
    message=$'The first phase of the installation has finished. We must now reboot the system in order for some changes to take effect and so you can log in as the new n8n user to continue the installation.\n\nWhen the system comes back online, please log in with the following credentials:\n    • Username: n8n\n    • Password: n8n=gr8!\n\nPro Tip: Write down that username and password so you have it handy.'
    whiptail --backtitle "n8n-pi Installer" --title "Time to Reboot" --msgbox "$message"  17 78
    $SUDO reboot || error_exit "$LINENO: Unable to reboot"

else 
    error_exit "$LINENO: Installation cancelled"
fi