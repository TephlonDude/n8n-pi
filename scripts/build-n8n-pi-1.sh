#!/bin/sh

SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi

echo "This script is designed to build a new n8n-pi from a base Raspbian Lite installation."
echo "This is the first of two scripts that need to be run."
echo "It will perform the following actions:"
echo "    1. Update Raspian Lite to the latest software"
echo "    2. Install dependencies"
echo "    3. Enable SSH (if it is not enabled)"
echo "    4. Rename the server"
echo "    5. Adds the n8n user"
echo "    6. Install base custom MOTD"
echo "    7. Reboot"

echo -n "Update repositories..."
$SUDO apt update
echo "Done!"

echo -n "Upgrading application packages..."
$SUDO apt upgrade -y
echo "Done!"

echo -n "Installing dependencies..."
$SUDO apt install figlet jq dialog -y
echo "Done!"

echo -n "Configuring SSH..."
$SUDO ssh-keygen -A && update-rc.d ssh enable && invoke-rc.d ssh start && STATUS=enabled
echo "Done!"

echo -n "Adding n8n user..."
$SUDO adduser --disabled-password --gecos "" n8n
echo 'n8n:n8n=gr8!' | $SUDO chpasswd
echo "Done!"

echo -n "Installing base custom MOTD..."
$SUDO wget -O /etc/update-motd.d/10-sysinfo https://raw.githubusercontent.com/TephlonDude/n8n-pi/master/motd/10-sysinfo
$SUDO chmod 755 /etc/update-motd.d/10-sysinfo
$SUDO rm -f /etc/update-motd.d/10-uname
echo "Done!"

echo 