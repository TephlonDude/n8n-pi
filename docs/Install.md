# Installing n8n-pi
There are two ways to install n8n-pi; the easy way and the DIY way. We will cover both of these.

# Easy Install
This option will get you up and running the quickest. You should be ready to start building your first flows in a few miutes.
## Overview
Essentially:
1. Download the image
1. Write the image to a microSD card
1. Boot the RPi
1. Point your browser to http://<RPi.IP.address>:5678

## Assumptions
For this installation, we are making the following assumptions. If this does not fit your situation, you may need to do...something. Learn a new skill... Buy (borrow) some inexpensive hardware...stuff like that!
* You have a Raspberry Pi 3 (This is what we did our testing on)
* You have a microSD card
* You are comfortable with working in a Linux environment from the command line
* You have 

## Download the Image
To do

## Write the Image to microSD card
To do

## Boot the RPi
To do

## Got to http://<RPi.IP.address>:5678
To do

# DIY Install
The DIY installation allows you to get your hands dirty by using the same installation scripts that I do for building the n8n-pi system. This way, if you want to customize or tweak your installation, then it's easy to do. Simply edit the files from the repository and go from there.

## Overview
Essentially:
1. Build Raspbian Lite microSD card
1. Enable SSH
1. Boot RPI from microSD card
1. SSH to RPi
1. Download *build-n8n-pi-1.sh*
1. Modify as desired (optional) and Make Executable
1. Run *build-n8n-pi-1.sh* and Follow Instructions

## Build Raspbian Lite microSD card
To do
## Enable SSH
To do
## Boot RPI from microSD card
To do
## SSH to RPi
To do
## Start the installation
Form the command prompt, enter the following:
```bash
wget -O - https://raw.githubusercontent.com/TephlonDude/n8n-pi/master/scripts/build-n8n-pi-1.sh | bash
```
This will download and run the first installation script. Simply follow the instructions from there.

