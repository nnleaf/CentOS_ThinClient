#!/bin/bash
#Nam - 20210513
#Thinclient Installation Script after Kickstart

#Create Logging File
touch /tmp/script_log.log
sh -c 'echo "=====================================================" >> /tmp/script_log.log'
sh -c 'echo "=================== Script Check ====================" >> /tmp/script_log.log'
sh -c 'echo "=====================================================" >> /tmp/script_log.log'

#Variables 
username1="Agent"
username2="ncriadmin"
#password="user1234"

#Enable ethernet
sed -i '/ONBOOT/d' /etc/sysconfig/network-scripts/ifcfg-e*
echo "ONBOOT=YES" >> /etc/sysconfig/network-scripts/ifcfg-e*
systemctl restart network
yum -y install network-manager-applet
sh -c 'echo "= [ 1/20] Enabled Ethernet & WiFi                   =" >> /tmp/script_log.log'

#Create User1 Account
/usr/sbin/useradd -m $username1
passwd -d $username1
#Create User2 Account
yum -y install sshpass
/usr/sbin/useradd -m $username2
(echo U2FsdGVkX1+IPWbhHzXcfKcvxgIym9LhfoEgihwOMB+YX979Q01D3YQm/MUap3GB | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:'password'; echo U2FsdGVkX1+IPWbhHzXcfKcvxgIym9LhfoEgihwOMB+YX979Q01D3YQm/MUap3GB | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:'password') | passwd $username2
sh -c 'echo "= [ 2/20] Users Created                             =" >> /tmp/script_log.log'

#Clean up Kickstart cronjob
sed -i '$d' /var/spool/cron/root
sh -c 'echo "= [ 3/20] Cleaned up Kickstart Cronjob              =" >> /tmp/script_log.log'

#Install xfce4 & set GUI
yum -y install epel-release
yum -y groupinstall X11
yum -y groups install "Xfce"
systemctl set-default graphical.target
echo "exec /usr/bin/xfce4-session" >> ~/.xinitrc
rm -f /usr/share/xsessions/openbox.desktop
#Hide ncriadmin from GDM login
cp -r /tmp/ks/hideuser/. /var/lib/AccountsService/users/.
sh -c 'echo "= [ 4/20] Installed XFCE4 & Set GUI                 =" >> /tmp/script_log.log'

#Install Packages
#FortiClient Online Method
#wget -O /tmp/ks/forticlient.rpm https://links.fortinet.com/forticlient/rhel/vpnagent
#yum -y install /tmp/ks/forticlient.rpm
#FortiClient Offline Method
yum -y install /tmp/ks/forticlient_vpn_7.0.0.0018_x86_64.rpm
yum -y install remmina gnome-system-monitor pulseaudio-utils fail2ban ufw
sh -c 'echo "= [ 5/20] Installed Packages                        =" >> /tmp/script_log.log'

#Restore xfce4 Panels
rm -rf /root/.config/xfce4/
rm -rf /home/"$username1"/.config/xfce4/
mkdir -p /root/.config/
mkdir -p /home/"$username1"/.config/
cp -r /tmp/ks/xfce4/ /root/.config/.
cp -r /tmp/ks/xfce4/ /home/"$username1"/.config/.
sh -c 'echo "= [ 6/20] Restore XFCE4 Panels                      =" >> /tmp/script_log.log'
#Add PulseAudio Defaults
cp -r /tmp/ks/pulse/ /etc/.
sh -c 'echo "= [ 7/20] Set PulseAudio Defaults                   =" >> /tmp/script_log.log'
#Add *.desktop files
cp -r /tmp/ks/autostart/ /home/"$username1"/.config/.
sh -c 'echo "= [ 8/20] Added autostart Files                     =" >> /tmp/script_log.log'
#Add /usr/local/bin/ Scripts
cp -r /tmp/ks/bin/ /usr/local/.
sh -c 'echo "= [ 9/20] Added scripts                             =" >> /tmp/script_log.log'
#Transfer Gnome Keyring Defaults
mkdir -p /home/"$username1"/.local/share/
cp -r /tmp/ks/keyrings/ /home/"$username1"/.local/share/.
sh -c 'echo "= [10/20] Added Gnome Keyring Defaults              =" >> /tmp/script_log.log'
#Transfer Remmina Template
cp -r /tmp/ks/remmina/ /home/"$username1"/.local/share/.
cp -r /tmp/ks/remmina/ /root/.
echo "@reboot /usr/local/bin/resetrdp.sh" >> /var/spool/cron/root
sh -c 'echo "= [11/20] Set Remmina Template                      =" >> /tmp/script_log.log'
#Set Wallpaper
mkdir -p /usr/share/backgrounds/images/
cp -r /tmp/ks/default.png /usr/share/backgrounds/images/default.png
sh -c 'echo "= [12/20] Set Wallpaper                             =" >> /tmp/script_log.log'
#Kiosk Mode
cp -r /home/"$username1"/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
sed -i 's/<channel name="xfce4-panel" version="1.0">/<channel name="xfce4-panel" version="1.0" locked="*" unlocked="tmp">/g' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
sh -c 'echo "= [13/20] Set Kiosk Mode                            =" >> /tmp/script_log.log'
#FortiClient DNS Issue
cp -r /etc/sysconfig/network-scripts/ifcfg-e* /root/.
cp -r /etc/sysconfig/network-scripts/ifcfg-l* /root/.
echo "@reboot /usr/local/bin/setdns.sh" >> /var/spool/cron/root
sh -c 'echo "= [14/20] Configured FortiClient Workaround         =" >> /tmp/script_log.log'
#Add public sshkeys
mkdir /home/"$username2"/.ssh
cp -r /tmp/ks/ssh/. /home/"$username2"/.ssh/.
sh -c 'echo "= [15/20] Added public sshkeys                      =" >> /tmp/script_log.log'
#Enabled Fail2Ban
cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
systemctl enable fail2ban
sh -c 'echo "= [16/20] Enabled fail2ban                          =" >> /tmp/script_log.log'
#Install x11vnc
yum -y install x11vnc
x11vnc -storepasswd "$(echo U2FsdGVkX19rLA9jbJQObDRL9qoMwfhkIFtiWBkSYzA= | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:'password')" /etc/x11vnc.pwd
cp -r /tmp/ks/x11vnc/x11vnc.service /etc/systemd/system/.
echo "@reboot /usr/local/bin/x11vnc.sh" >> /var/spool/cron/root
sh -c 'echo "= [17/20] Installed x11vnc                          =" >> /tmp/script_log.log'

#Set ownership to users's folders
chmod -R +x /usr/local/bin/
chown -R "$username1":"$username1" /home/"$username1"/
chown -R "$username2":"$username2" /home/"$username2"/
#Set ownership to allow Agent to run setdns.sh
chown root.root /usr/local/bin/setdns.sh
chmod 4755 /usr/local/bin/setdns.sh
#Set ownership to allow Agent to run instructions.sh
chown root.root /usr/local/bin/instructions.sh
chmod 4755 /usr/local/bin/instructions.sh
#Set Agent sudo permissions
sed -i "/Allow root to run any commands anywhere/ a ${username1} ALL=NOPASSWD: /usr/local/bin/setdns.sh,/usr/local/bin/instructions.sh" /etc/sudoers
#Set ncriadmin sudo permissions
sed -i "/Allow root to run any commands anywhere/ a ${username2} ALL=ALL, !/bin/su" /etc/sudoers
#Set openssh permissions
sed -i '/PasswordAuthentication yes/d' /etc/ssh/sshd_config
sed -i '/Authentication:/ a Protocol 2' /etc/ssh/sshd_config
sed -i '/Authentication:/ a PermitRootLogin prohibit-password' /etc/ssh/sshd_config
sed -i '/Authentication:/ a PermitEmptyPasswords no' /etc/ssh/sshd_config
sed -i '/Authentication:/ a PasswordAuthentication no' /etc/ssh/sshd_config
sh -c 'echo "= [18/20] Set Permissions                           =" >> /tmp/script_log.log'

#Update CentOS
yum -y update
sh -c 'echo "= [19/20] Update CentOS                             =" >> /tmp/script_log.log'

#Cleanup
rm -rf /tmp/ks/
sh -c 'echo "= [20/20] Cleanup and Reboot                        =" >> /tmp/script_log.log'
sudo reboot