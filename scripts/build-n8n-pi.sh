#!/bin/sh

echo "This script is designed to build a new n8n-pi from a base Raspbian Lite installation."
echo "It will perform the following actions:"
echo "    1. Update Raspian Lite to the latest software"
echo "    2. Enable SSH (if it is not enabled)"
echo "    3. Adds the n8n user"
echo "    4. Install custom MOTD"

echo -n "Update repositories..."
apt update
echo "Done!"

echo -n "Upgrading application packages..."
apt upgrade -y
echo "Done!"

echo -n "Configuring SSH..."
ssh-keygen -A &&
update-rc.d ssh enable &&
invoke-rc.d ssh start &&
STATUS=enabled
echo "Done!"

echo -n "Adding n8n user..."
useradd n8n -p "n8n=gr8!" -d /home/n8n -s /bin/bash -G sudo n8n --gecos
echo "Done!"

echo -n "Installing custom MOTD..."
apt install figlet -y
