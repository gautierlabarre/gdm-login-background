#!/bin/bash
# Autor: Thiago Silva
# Contact: thiagos.dasilva@gmail.com
# URL: https://github.com/thiggy01/ubuntu-20.04-change-gdm-background
# =================================================================== #

# Check if script is run by root.
if [ "$(id -u)" -ne 0 ] ; then
    echo 'This script must be run as root.'
    exit 1
fi

# Check if glib 2.0 development libraries are installed.
if [ ! $(dpkg -s libglib2.0-dev-bin | grep Status | cut -d ' ' -f 4) \
    == installed ]; then
    echo 'Additional glib 2.0 libraries need to be installed.'
    read -p 'Type y or Y to proceed. Any other key to exit: ' -n 1
    if [[ "$REPLY" =~ ^[yY]$ ]]; then
	apt install libglib2.0-dev-bin
    else
	echo
	exit 1
    fi
fi

test () {
echo 'yeah'
}

[ "$1" == "--restore" ] && test

echo "tout est bon"

echo $1

echo $name

if [[ $(file --mime-type -b "$1") == image/*g ]]; then

echo 'ok ok image push'
fi