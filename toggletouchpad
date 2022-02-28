#!/usr/bin/env bash
if [[ "$(gsettings get org.gnome.desktop.peripherals.touchpad send-events)" == "'enabled'" ]];
then
    gsettings set org.gnome.desktop.peripherals.touchpad send-events 'disabled'

elif [[ "$(gsettings get org.gnome.desktop.peripherals.touchpad send-events)" == "'disabled'" ]];
then
    gsettings set org.gnome.desktop.peripherals.touchpad send-events 'enabled'
else
    gnome-terminal -e $HOME/Coding-Projects/QOLbashscripts/toggletouchpad_error.sh
fi