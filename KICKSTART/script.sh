#!/bin/bash
#Nam - 20210513
#Thinclient Installation Script after Kickstart

#VARIABLES
USERNAME="Agent"
PASSWORD="user1234"

#Create User Account
/usr/sbin/useradd -m $USERNAME
passwd -d $USERNAME
#/usr/bin/echo "$USERNAME:$PASSWORD" | /usr/sbin/chpasswd

#Enable ethernet
sed -i '/ONBOOT="no"/d' /etc/sysconfig/network-scripts/ifcfg-e*
sed -i '/ONBOOT=no/d' /etc/sysconfig/network-scripts/ifcfg-e*
sed -i '/ONBOOT="YES"/d' /etc/sysconfig/network-scripts/ifcfg-e*
sed -i '/ONBOOT=yes/d' /etc/sysconfig/network-scripts/ifcfg-e*
echo "ONBOOT=YES" >> /etc/sysconfig/network-scripts/ifcfg-e*
systemctl restart network

#Install xfce & set GUI
yum -y install epel-release
yum -y groupinstall X11
yum -y groups install "Xfce"
systemctl set-default graphical.target
echo "exec /usr/bin/xfce4-session" >> ~/.xinitrc
rm -f /usr/share/xsessions/openbox.desktop

#Install Packages
wget -O /tmp/ks/forticlient.rpm https://links.fortinet.com/forticlient/rhel/vpnagent
yum -y install /tmp/ks/forticlient.rpm
yum -y install remmina gnome-system-monitor pulseaudio-utils

#Restore xfce4 panels
rm -rf /root/.config/xfce4/
rm -rf /home/"$USERNAME"/.config/xfce4/
mkdir -p /root/.config/
mkdir -p /home/"$USERNAME"/.config/
cp -r /tmp/ks/xfce4/ /root/.config/.
cp -r /tmp/ks/xfce4/ /home/"$USERNAME"/.config/.
#Add *.desktop files
cp -r /tmp/ks/autostart/ /home/"$USERNAME"/.config/.
#Transfer Gnome Keyring
cp -r /tmp/ks/keyrings/ /home/"$USERNAME"/.local/share/.
#Transfer Remmina Template
cp -r /tmp/ks/remmina /home/"$USERNAME"/.local/share/.
#Set Wallpaper
mkdir -p /usr/share/backgrounds/images/
cp -r /tmp/ks/default.png /usr/share/backgrounds/images/default.png
#Kiosk Mode
cp -r /home/"$USERNAME"/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
sed -i 's/<channel name="xfce4-panel" version="1.0">/<channel name="xfce4-panel" version="1.0" locked="*" unlocked="root">/g' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml



#Set ownership to created user's folder
chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/

#Update CentOS
yum -y update

#Cleanup
rm -rf /tmp/ks/
sed -i '$d' /var/spool/cron/root
sudo reboot