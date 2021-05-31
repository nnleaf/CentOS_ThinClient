#!/bin/bash
#Nam - 20210513
#Thinclient Installation Script after Kickstart

username="Agent"
#password="user1234"

#Create User Account
/usr/sbin/useradd -m $username
passwd -d $username
#/usr/bin/echo "$username:$password" | /usr/sbin/chpasswd

#Clean up Kickstart cronjob
sed -i '$d' /var/spool/cron/root

#Enable ethernet
sed -i '/ONBOOT="NO"/d' /etc/sysconfig/network-scripts/ifcfg-e*
sed -i '/ONBOOT="no"/d' /etc/sysconfig/network-scripts/ifcfg-e*
sed -i '/ONBOOT=no/d' /etc/sysconfig/network-scripts/ifcfg-e*
sed -i '/ONBOOT=NO/d' /etc/sysconfig/network-scripts/ifcfg-e*
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

#Restore xfce4 Panels
rm -rf /root/.config/xfce4/
rm -rf /home/"$username"/.config/xfce4/
mkdir -p /root/.config/
mkdir -p /home/"$username"/.config/
cp -r /tmp/ks/xfce4/ /root/.config/.
cp -r /tmp/ks/xfce4/ /home/"$username"/.config/.
#Add PulseAudio Defaults
cp -r /tmp/ks/pulse/ /etc/.
#Add *.desktop files
cp -r /tmp/ks/autostart/ /home/"$username"/.config/.
#Add /usr/local/bin/ Scripts
cp -r /tmp/ks/bin/ /usr/local/.
#Transfer Gnome Keyring Defaults
mkdir -p /home/"$username"/.local/share/
cp -r /tmp/ks/keyrings/ /home/"$username"/.local/share/.
#Transfer Remmina Template
cp -r /tmp/ks/remmina/ /home/"$username"/.local/share/.
#Set Wallpaper
mkdir -p /usr/share/backgrounds/images/
cp -r /tmp/ks/default.png /usr/share/backgrounds/images/default.png
#Kiosk Mode
cp -r /home/"$username"/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
sed -i 's/<channel name="xfce4-panel" version="1.0">/<channel name="xfce4-panel" version="1.0" locked="*" unlocked="root">/g' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
#FortiClient DNS Issue
cp -r /etc/sysconfig/network-scripts/ /root/.
echo "@reboot /usr/local/bin/setdns.sh" >> /var/spool/cron/root

#Set ownership to user's folders
chmod -R +x /usr/local/bin/
chown -R "$username":"$username" /home/"$username"/

#Update CentOS
yum -y update

#Cleanup
rm -rf /tmp/ks/
sudo reboot