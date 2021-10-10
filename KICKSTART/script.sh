#!/bin/bash
#Nam - 20210513
#Thinclient Installation Script after Kickstart

#Create Logging File
touch /tmp/script_log.log
sh -c 'echo "=====================================================" >> /tmp/script_log.log'
sh -c 'echo "=================== Build Details ===================" >> /tmp/script_log.log'
sh -c 'echo "=====================================================" >> /tmp/script_log.log'
sh -c 'echo "=                    Version 1.3                    =" >> /tmp/script_log.log'
sh -c 'echo "=                Released 2021.10.09                =" >> /tmp/script_log.log'
sh -c 'echo "=====================================================" >> /tmp/script_log.log'
sh -c 'echo "=================== Script Check ====================" >> /tmp/script_log.log'
sh -c 'echo "=====================================================" >> /tmp/script_log.log'

#Variables 
username1="Agent"
username2="ncriadmin"

#Enable ethernet
sed -i '/ONBOOT/d' /etc/sysconfig/network-scripts/ifcfg-e*
echo "ONBOOT=YES" >> /etc/sysconfig/network-scripts/ifcfg-e*
systemctl restart network
sleep 30
yum -y install network-manager-applet
sh -c 'echo "= [ 1/22] Enabled Ethernet & WiFi                   =" >> /tmp/script_log.log'

#Create User1 Account
/usr/sbin/useradd -m $username1
passwd -d $username1
#Create User2 Account
yum -y install sshpass
/usr/sbin/useradd -m $username2
(echo U2FsdGVkX1+IPWbhHzXcfKcvxgIym9LhfoEgihwOMB+YX979Q01D3YQm/MUap3GB | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:'password'; echo U2FsdGVkX1+IPWbhHzXcfKcvxgIym9LhfoEgihwOMB+YX979Q01D3YQm/MUap3GB | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:'password') | passwd $username2
sh -c 'echo "= [ 2/22] Users Created                             =" >> /tmp/script_log.log'

#Clean up Kickstart cronjob
rm -r /var/spool/cron/root
cp /tmp/ks/cron/root /var/spool/cron/.
chown root:root /var/spool/cron/root
chmod 600 /var/spool/cron/root
sh -c 'echo "= [ 3/22] Cleaned up Kickstart Cronjob              =" >> /tmp/script_log.log'

#Install xfce4 & set GUI
yum -y install epel-release
yum -y groupinstall X11
yum -y groups install "Xfce"
systemctl set-default graphical.target
echo "exec /usr/bin/xfce4-session" >> ~/.xinitrc
rm -f /usr/share/xsessions/openbox.desktop
#Hide ncriadmin from GDM login
cp -r /tmp/ks/hideuser/. /var/lib/AccountsService/users/.
sh -c 'echo "= [ 4/22] Installed XFCE4 & Set GUI                 =" >> /tmp/script_log.log'

#Install Packages
#FortiClient Online Method
#wget -O /tmp/ks/forticlient.rpm https://links.fortinet.com/forticlient/rhel/vpnagent
#yum -y install /tmp/ks/forticlient.rpm
#Offline Method Install
yum -y install /tmp/ks/forti/forticlient_vpn_7.0.0.0018_x86_64.rpm
#Install Flatpak packages
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.microsoft.Teams
flatpak install -y flathub us.zoom.Zoom
#Other Packages
yum -y install remmina gnome-system-monitor pulseaudio-utils alsa-tools fail2ban tmux
#Install speedtest-cli
wget -P /usr/local/bin/ https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
sh -c 'echo "= [ 5/22] Installed Packages                        =" >> /tmp/script_log.log'

#Restore xfce4 Panels
rm -rf /root/.config/xfce4/
rm -rf /home/"$username1"/.config/xfce4/
mkdir -p /root/.config/
mkdir -p /home/"$username1"/.config/
cp -r /tmp/ks/xfce4/ /root/.config/.
cp -r /tmp/ks/xfce4/ /home/"$username1"/.config/.
sh -c 'echo "= [ 6/22] Restore XFCE4 Panels                      =" >> /tmp/script_log.log'
#Add PulseAudio Defaults
cp -r /tmp/ks/pulse/ /etc/.
sh -c 'echo "= [ 7/22] Set PulseAudio Defaults                   =" >> /tmp/script_log.log'
#Add *.desktop files
cp -r /tmp/ks/autostart/ /home/"$username1"/.config/.
sh -c 'echo "= [ 8/22] Added autostart Files                     =" >> /tmp/script_log.log'
#Add /usr/local/bin/ Scripts
cp -r /tmp/ks/bin/ /usr/local/.
sh -c 'echo "= [ 9/22] Added scripts                             =" >> /tmp/script_log.log'
#Transfer Gnome Keyring Defaults
mkdir -p /home/"$username1"/.local/share/
cp -r /tmp/ks/keyrings/ /home/"$username1"/.local/share/.
sh -c 'echo "= [10/22] Added Gnome Keyring Defaults              =" >> /tmp/script_log.log'
#Transfer Remmina Template
cp -r /tmp/ks/remmina/ /home/"$username1"/.local/share/.
cp -r /tmp/ks/remmina/ /root/.
sh -c 'echo "= [11/22] Set Remmina Template                      =" >> /tmp/script_log.log'
#Set Wallpaper
mkdir -p /usr/share/backgrounds/images/
cp -r /tmp/ks/default.png /usr/share/backgrounds/images/default.png
sh -c 'echo "= [12/22] Set Wallpaper                             =" >> /tmp/script_log.log'
#Kiosk Mode
cp -r /home/"$username1"/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
sed -i 's/<channel name="xfce4-panel" version="1.0">/<channel name="xfce4-panel" version="1.0" locked="*" unlocked="tmp">/g' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
sh -c 'echo "= [13/22] Set Kiosk Mode                            =" >> /tmp/script_log.log'
#Add FortiClient database file
rm -r /etc/forticlient/config.db
cp /tmp/ks/forti/config.db /etc/forticlient/.
chown root:root /etc/forticlient/config.db
chmod 600 /etc/forticlient/config.db
#FortiClient DNS Issue
cp -r /etc/sysconfig/network-scripts/ifcfg-e* /root/.
cp -r /etc/sysconfig/network-scripts/ifcfg-l* /root/.
sh -c 'echo "= [14/22] Configured FortiClient                    =" >> /tmp/script_log.log'
#Add public sshkeys
mkdir /home/"$username2"/.ssh
cp -r /tmp/ks/ssh/. /home/"$username2"/.ssh/.
sh -c 'echo "= [15/22] Added public sshkeys                      =" >> /tmp/script_log.log'
#Enabled Fail2Ban
cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
systemctl enable fail2ban
#Enabled firewalld
systemctl unmask firewalld
systemctl start firewalld
systemctl enable firewalld
sh -c 'echo "= [16/22] Enabled firewalld & fail2ban              =" >> /tmp/script_log.log'
#Install x11vnc
yum -y install x11vnc
x11vnc -storepasswd "$(echo U2FsdGVkX19rLA9jbJQObDRL9qoMwfhkIFtiWBkSYzA= | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:'password')" /etc/x11vnc.pwd
cp -r /tmp/ks/x11vnc/x11vnc.service /etc/systemd/system/.
sh -c 'echo "= [17/22] Installed x11vnc                          =" >> /tmp/script_log.log'
mkdir /home/ncriadmin/logs
sh -c 'echo "= [18/22] Added Network Test Logs                   =" >> /tmp/script_log.log'
#Appdata Permissions
sed -i 's/filesystems=xdg-download;/filesystems=/g' /var/lib/flatpak/app/com.microsoft.Teams/x86_64/stable/b06304204e91071deb93fd186b47f6b5e0d6c059aa8a30300e7f67be804c566c/metadata
sed -i 's/filesystems=~\/Documents\/Zoom:create;~\/.zoom:create;/filesystems=/g' /var/lib/flatpak/app/us.zoom.Zoom/current/active/metadata
sh -c 'echo "= [19/22] Added Flatpak Permissions                 =" >> /tmp/script_log.log'

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
sh -c 'echo "= [20/22] Set Permissions                           =" >> /tmp/script_log.log'

#Update CentOS
yum -y update
sh -c 'echo "= [21/22] Update CentOS                             =" >> /tmp/script_log.log'

#Cleanup
rm -rf /tmp/ks/
sh -c 'echo "= [22/22] Cleanup and Reboot                        =" >> /tmp/script_log.log'
sh -c 'echo "=====================================================" >> /tmp/script_log.log'
sudo reboot
reboot