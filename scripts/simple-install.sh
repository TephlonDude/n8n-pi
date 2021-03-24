#!/bin/bash
sudo apt update
sudo apt upgrade
sudo apt install build-essential python

curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install nodejs

cd ~
mkdir ~/.nodejs_global
npm config set prefix ~/.nodejs_global
echo 'export PATH=~/.nodejs_global/bin:$PATH' | tee --append ~/.profile
source ~/.profile
npm install n8n -g

cd ~
npm install pm2@latest -g
pm2 start n8n
pm2 startup
# make sure to run the command mentioned 
pm2 save
