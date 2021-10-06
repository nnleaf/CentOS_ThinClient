#!/bin/bash
#Nam - 20210813
#Update Script v.1.1 > Teams/Zoom Build

username1="Agent"

echo "====================================================="
echo "======================= UPDATE ======================"
echo "====================================================="
echo "=              Version 1.1 > Teams/Zoom             ="
echo "=                Released 2021.10.06                ="
echo "====================================================="

#Temp folder
sudo mkdir /tmp/update/

sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub com.microsoft.Teams
sudo flatpak override com.microsoft.Teams --nofilesystem==/


#Install Zoom
wget -P /tmp/update/ https://zoom.us/client/latest/zoom_x86_64.rpm
sudo yum -y localinstall /tmp/update/zoom_x86_64.rpm

#Create GUI Dock Icons
#1. Delete existing xfce files
#2. Copy over xfce dock with teams and zoom


#Restore xfce4 Panels
sudo rm -rf /root/.config/xfce4/
sudo rm -rf /home/"$username1"/.config/xfce4/
sudo mkdir -p /root/.config/
sudo mkdir -p /home/"$username1"/.config/
sudo cp -r /tmp/update_flex/xfce4/ /root/.config/.
sudo cp -r /tmp/update_flex/xfce4/ /home/"$username1"/.config/.


#Cleanup
sudo rm -r /tmp/update/ /tmp/update_flex