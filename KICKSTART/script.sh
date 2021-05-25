#!/bin/bash
#Nam - 20210513
#Thinclient Installation Script after Kickstart

#VARIABLES
USERNAME="Agent"
PASSWORD="user1234"

#Create User Account
/usr/sbin/useradd -m $USERNAME
/usr/bin/echo "$USERNAME:$PASSWORD" | /usr/sbin/chpasswd

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
wget -O /tmp/ks/google-chrome.rpm https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
wget -O /tmp/ks/teams.rpm https://packages.microsoft.com/yumrepos/ms-teams/teams-1.3.00.25560-1.x86_64.rpm
wget -O /tmp/ks/forticlient.rpm https://links.fortinet.com/forticlient/rhel/vpnagent
yum -y install /tmp/ks/teams.rpm
yum -y install /tmp/ks/google-chrome.rpm
yum -y install /tmp/ks/forticlient.rpm
yum -y install remmina gnome-system-monitor

#Restore xfce4 panels
rm -rf /root/.config/xfce4/
rm -rf /home/"$USERNAME"/.config/xfce4/
mkdir -p /root/.config/
mkdir -p /home/"$USERNAME"/.config/
cp -r /tmp/ks/xfce4/ /root/.config/.
cp -r /tmp/ks/xfce4/ /home/"$USERNAME"/.config/.
#Give ownership to created userNAME
chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/

#Set Wallpaper
mkdir -p /usr/share/backgrounds/images/
cp -r /tmp/ks/default.png /usr/share/backgrounds/images/default.png

#Update CentOS
yum -y update

#Transfer Gnome Keyring
mkdir -p /home/"$USERNAME"/.local/share/keyrings/
cp -r /tmp/ks/keyrings/ /home/"$USERNAME"/.local/share/.
chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.local/share/keyrings/

#Cleanup
rm -rf /tmp/ks/
sed -i '$d' /var/spool/cron/root
sudo reboot