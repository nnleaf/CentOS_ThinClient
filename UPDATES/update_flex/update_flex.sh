#!/bin/bash
#Nam - 20210813
#Update Script v.1.1 > Teams/Zoom Build
#
# INSTRUCTIONS
#
# 1. Transfer to /tmp/
# 2. SSH into client and run as SUDO
#    

#Variables
username1="Agent"

echo "====================================================="
echo "======================= UPDATE ======================"
echo "====================================================="
echo "=              Version 1.1 > 1.3 Teams/Zoom         ="
echo "=                Released 2021.10.06                ="
echo "====================================================="

#Temp folder
mkdir /tmp/update/

#Install Teams & Zoom Flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.microsoft.Teams
flatpak override com.microsoft.Teams --nofilesystem==/
flatpak install -y flathub us.zoom.Zoom

#Add new xfce4 panels
sed -i 's/<channel name="xfce4-panel" version="1.0" locked="\*" unlocked="tmp">/<channel name="xfce4-panel" version="1.0">/g' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
rm -rf /root/.config/xfce4/
rm -rf /home/"$username1"/.config/xfce4/
mkdir -p /root/.config/
mkdir -p /home/"$username1"/.config/
cp -r /tmp/update_flex/xfce4/ /root/.config/.
cp -r /tmp/update_flex/xfce4/ /home/"$username1"/.config/.
cp -r /home/"$username1"/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
sed -i 's/<channel name="xfce4-panel" version="1.0">/<channel name="xfce4-panel" version="1.0" locked="*" unlocked="tmp">/g' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml

#Appdata Permissions
cp /tmp/update_flex/resetflatpak.sh /usr/local/bin/.
sed -i 's/filesystems=xdg-download;/filesystems=/g' /var/lib/flatpak/app/com.microsoft.Teams/x86_64/stable/b06304204e91071deb93fd186b47f6b5e0d6c059aa8a30300e7f67be804c566c/metadata
sed -i 's/filesystems=~\/Documents\/Zoom:create;~\/.zoom:create;/filesystems=/g' /var/lib/flatpak/app/us.zoom.Zoom/current/active/metadata

#Set cronjobs
rm -r /var/spool/cron/root
cp /tmp/update_flex/cron/root /var/spool/cron/.
chown root:root /var/spool/cron/root
chmod 600 /var/spool/cron/root

#Set permissions
chmod -R +x /usr/local/bin/
chown -R "$username1":"$username1" /home/"$username1"/
#Kill User Session to set xfce4 panels
pkill -KILL -u Agent

#Enable firewalld
systemctl unmask firewalld
systemctl start firewalld
systemctl enable firewalld

#Cleanup
rm -r /tmp/update/ /tmp/update_flex