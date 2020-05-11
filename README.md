<img align="right" width="300" height="300" src="https://robohash.org/n8n-pi">

# n8n-pi
 Tools and Images to Build a Raspberry Pi n8n server

 ![GitHub issues](https://img.shields.io/github/issues-raw/TephlonDude/n8n-pi) ![GitHub repo size](https://img.shields.io/github/repo-size/TephlonDude/n8n-pi) ![GitHub](https://img.shields.io/github/license/TephlonDude/n8n-pi) ![GitHub last commit](https://img.shields.io/github/last-commit/TephlonDude/n8n-pi) ![GitHub release (latest by date)](https://img.shields.io/github/v/release/TephlonDude/n8n-pi)

# Introduction
The purpose of this project is to create a Raspberry Pi image preconfigured with n8n so that it runs out of the box.

## What is n8n?
[n8n](https://n8n.io) is a no-code/low code environment used to connect and automate different systems and services. It is programmed using a series of connected nodes that receive, transform, and then transmit date from and to other nodes. Each node represents a service or system allowing these different entities to interact. All of this is done using a WebUI.

## Why n8n-pi?
Whevever a new technology is released, two common barriers often prevent potential users from trying out the technology:
1. System costs
1. Installation & configuration challenges

The n8n-pi project eliminates these two roadblocks by preconfiguring a working system that runs on easily available, low cost hardware. For as little as $40 and a few minutes, they can have a full n8n system up and running.

## Thanks!
This project would not be possible if it was not for the help of the following:
* [n8n Project](https://n8n.io/)
    * [GitHub](https://github.com/n8n-io/n8n)
    * [Community](https://community.n8n.io/)
* [Raspberry Pi](https://www.raspberrypi.org/)
    * [Documentation](https://www.raspberrypi.org/documentation/)
    * [Raspian](https://www.raspberrypi.org/downloads/raspbian/)
* [GitHub](https://github.com/)
* [Docsify](https://docsify.js.org/)

# Installation
There are two different ways to get the n8n-pi up and running:
1. **Image Build** - You essentially download a pre-built image, write it to a microSD card, and boot from your RPi. You don't really learn a whole lot from the process but you are up and running quickly.
2. **DIY Build** - You run a pre-configured set of scripts that will do most of the heavy lifting for you but you can open up and edit the scripts to learn what they do and modify them to fit your needs.