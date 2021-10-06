#!/bin/bash
#Nam - 20210813
#Update Script v.1.1 > Teams/Zoom Build
echo "====================================================="
echo "======================= UPDATE ======================"
echo "====================================================="
echo "=              Version 1.1 > Teams/Zoom             ="
echo "=                Released 2021.10.06                ="
echo "====================================================="

mkdir /tmp/update/

sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub com.microsoft.Teams
sudo flatpak override com.microsoft.Teams --nofilesystem==/


#Install Zoom
wget -P /tmp/update/ https://zoom.us/client/latest/zoom_x86_64.rpm
sudo yum -y localinstall /tmp/update/zoom_x86_64.rpm

#Create GUI Dock Icons
#1. Delete existing xfce files
#2. Copy over xfce dock with teams and zoom 



#Cleanup
sudo rm -r /tmp/update/