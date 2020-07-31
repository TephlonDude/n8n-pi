# Troubleshooting
Sometimes things don't go as planned. If that happens to you, take a look at some of the issues that we ran into during this project. Maybe we've already solved your challenge and you are good to go!

# Raspberry Pi
Trouble getting the Raspberry Pi to work as expected.
## Raspberry Pi does not boot after copying image file to microSD card
### **Challenge**
After the image file is copied to the microSD card and the card is put into the Raspberry Pi, the Raspberry Pi will not boot when turned on.
### **Potential Problem**
The image file is not copied to the microSD card like you would copy a normal file to a flash drive. The image file needs to be written to the microSD card.
### **Resolution**
Write the image file to the microSD card using a program such as [Raspberry Pi Imager](https://www.raspberrypi.org/downloads/). This will properly prep the microSD card to boot the Raspberry Pi.
### **Resources**
* [Installing Operating System Images](https://www.raspberrypi.org/documentation/installation/installing-images/README.md)
* [Raspberry Pi Imager](https://www.raspberrypi.org/downloads/)

## Can't SSH to RPi in order to Start Installation
### **Challenge**
When you attemtp to SSH to the newly imaged Raspberry Pi, you are refused access.
### **Potential Problem**
This is often caused by the SSH file not being added to the Raspberry Pi SD card before it is put into the Raspberry Pi.
### **Resolution**
Crate an SSH file in the root of the boot partition on the SD card while it is in a different computer and then replace the card back into the Raspberry Pi and reboot. This should resove the issue
### **Resources**
* [Enable SSH](http://n8n-pi.tephlon.xyz/#/Install?id=enable-ssh)
# Permissions

# Security

# Install Errors
## Build Script 1

## Build Script 2
