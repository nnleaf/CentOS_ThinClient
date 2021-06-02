#!/bin/bash
#Nam - 20210513
#Thinclient Installation Script after Kickstart

#Create Logging File
touch /tmp/script_log.log
sh -c 'echo "=========================================" >> /tmp/script_log.log'
sh -c 'echo "============= Script Check ==============" >> /tmp/script_log.log'
sh -c 'echo "=========================================" >> /tmp/script_log.log'

#Variables
username="Agent"
#password="user1234"

#Create User Account
/usr/sbin/useradd -m $username
passwd -d $username
#/usr/bin/echo "$username:$password" | /usr/sbin/chpasswd
sh -c 'echo "[ 1/17] User Created" >> /tmp/script_log.log'

#Clean up Kickstart cronjob
sed -i '$d' /var/spool/cron/root
sh -c 'echo "[ 2/17] Cleaned up Kickstart Cronjob" >> /tmp/script_log.log'

#Enable ethernet
sed -i '/ONBOOT/d' /etc/sysconfig/network-scripts/ifcfg-e*
echo "ONBOOT=YES" >> /etc/sysconfig/network-scripts/ifcfg-e*
systemctl restart network
sh -c 'echo "[ 3/17] Enabled Ethernet" >> /tmp/script_log.log'

#Install xfce4 & set GUI
yum -y install epel-release
yum -y groupinstall X11
yum -y groups install "Xfce"
systemctl set-default graphical.target
echo "exec /usr/bin/xfce4-session" >> ~/.xinitrc
rm -f /usr/share/xsessions/openbox.desktop
sh -c 'echo "[ 4/17] Installed XFCE4 & Set GUI" >> /tmp/script_log.log'

#Install Packages
#FortiClient Online Method
#wget -O /tmp/ks/forticlient.rpm https://links.fortinet.com/forticlient/rhel/vpnagent
#yum -y install /tmp/ks/forticlient.rpm
#FortiClient Offline Method
yum -y install /tmp/ks/forticlient_vpn_7.0.0.0018_x86_64.rpm
yum -y install remmina gnome-system-monitor pulseaudio-utils
sh -c 'echo "[ 5/17] Installed Packages" >> /tmp/script_log.log'

#Restore xfce4 Panels
rm -rf /root/.config/xfce4/
rm -rf /home/"$username"/.config/xfce4/
mkdir -p /root/.config/
mkdir -p /home/"$username"/.config/
cp -r /tmp/ks/xfce4/ /root/.config/.
cp -r /tmp/ks/xfce4/ /home/"$username"/.config/.
sh -c 'echo "[ 6/17] Restore XFCE4 Panels" >> /tmp/script_log.log'
#Add PulseAudio Defaults
cp -r /tmp/ks/pulse/ /etc/.
sh -c 'echo "[ 7/17] Set PulseAudio Defaults" >> /tmp/script_log.log'
#Add *.desktop files
cp -r /tmp/ks/autostart/ /home/"$username"/.config/.
sh -c 'echo "[ 8/17] Added autostart Files" >> /tmp/script_log.log'
#Add /usr/local/bin/ Scripts
cp -r /tmp/ks/bin/ /usr/local/.
sh -c 'echo "[ 9/17] Added scripts" >> /tmp/script_log.log'
#Transfer Gnome Keyring Defaults
mkdir -p /home/"$username"/.local/share/
cp -r /tmp/ks/keyrings/ /home/"$username"/.local/share/.
sh -c 'echo "[10/17] Added Gnome Keyring Defaults" >> /tmp/script_log.log'
#Transfer Remmina Template
cp -r /tmp/ks/remmina/ /home/"$username"/.local/share/.
sh -c 'echo "[11/17] Set Remmina Template" >> /tmp/script_log.log'
#Set Wallpaper
mkdir -p /usr/share/backgrounds/images/
cp -r /tmp/ks/default.png /usr/share/backgrounds/images/default.png
sh -c 'echo "[12/17] Set Wallpaper" >> /tmp/script_log.log'
#Kiosk Mode
cp -r /home/"$username"/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
sed -i 's/<channel name="xfce4-panel" version="1.0">/<channel name="xfce4-panel" version="1.0" locked="*" unlocked="tmp">/g' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
sh -c 'echo "[13/17] Set Kiosk Mode" >> /tmp/script_log.log'
#FortiClient DNS Issue
cp -r /etc/sysconfig/network-scripts/ifcfg-e* /root/.
echo "@reboot /usr/local/bin/setdns.sh" >> /var/spool/cron/root
sh -c 'echo "[14/17] Configured FortiClient Workaround" >> /tmp/script_log.log'

#Set ownership to user's folders
chmod -R +x /usr/local/bin/
chown -R "$username":"$username" /home/"$username"/
sh -c 'echo "[15/17] Set Permissions" >> /tmp/script_log.log'

#Update CentOS
yum -y update
sh -c 'echo "[16/17] Update CentOS" >> /tmp/script_log.log'

#Cleanup
rm -rf /tmp/ks/
sh -c 'echo "[17/17] Cleanup and Reboot" >> /tmp/script_log.log'

#Added Instructions to Check Script
sh -c 'echo "=========================================" >> /tmp/script_log.log'
sh -c 'echo "============= Instructions ==============" >> /tmp/script_log.log'
sh -c 'echo "=========================================" >> /tmp/script_log.log'
sh -c 'echo "1. Set FortiClient VPN Configuration" >> /tmp/script_log.log'
sh -c 'echo "Connection Name - NCRI_VPN" >> /tmp/script_log.log'
sh -c 'echo "Description - NCRI_VPN" >> /tmp/script_log.log'
sh -c 'echo "Remote Gateway - TORSEC1.NCRI.COM" >> /tmp/script_log.log'
sh -c 'echo "Customize Port - 8443" >> /tmp/script_log.log'
sh -c 'echo "2. Set RDP Credentials" >> /tmp/script_log.log'
sh -c 'echo "3. Check VPN connection" >> /tmp/script_log.log'
sh -c 'echo "4. Check " >> /tmp/script_log.log'

sudo reboot