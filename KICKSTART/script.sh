#!/bin/bash
#Nam - 20210513
#Thinclient Installation Script after Kickstart

#Create Logging File
touch /tmp/install.log
sh -c 'echo "=====================================================" >> /tmp/install.log'
sh -c 'echo "=================== Build Details ===================" >> /tmp/install.log'
sh -c 'echo "=====================================================" >> /tmp/install.log'
sh -c 'echo "=                   Version 1.4.1                   =" >> /tmp/install.log'
sh -c 'echo "=                Released 2022.01.21                =" >> /tmp/install.log'
sh -c 'echo "=            Installed $(date +%Y-%m-%d_%H%M%S)            =" >> /tmp/install.log'
sh -c 'echo "=             `sudo dmidecode -t system | grep Product`            =" >> /tmp/install.log'
sh -c 'echo "=              `sudo dmidecode -t system | grep Serial`             =" >> /tmp/install.log'
sh -c 'echo "=====================================================" >> /tmp/install.log'

#Variables 
username1="Agent"
username2="ncriadmin"

#Enable ethernet
sed -i '/ONBOOT/d' /etc/sysconfig/network-scripts/ifcfg-e*
echo "ONBOOT=YES" >> /etc/sysconfig/network-scripts/ifcfg-e*
systemctl restart network
sleep 30
yum -y install network-manager-applet
sh -c 'echo "= [ 1/25] Ethernet & WiFi Enabled                   =" >> /tmp/install.log'

#Create User1 Account
/usr/sbin/useradd -m $username1
passwd -d $username1
#Create User2 Account
yum -y install sshpass
/usr/sbin/useradd -m $username2
(echo U2FsdGVkX1+IPWbhHzXcfKcvxgIym9LhfoEgihwOMB+YX979Q01D3YQm/MUap3GB | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:'password'; echo U2FsdGVkX1+IPWbhHzXcfKcvxgIym9LhfoEgihwOMB+YX979Q01D3YQm/MUap3GB | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:'password') | passwd $username2
sh -c 'echo "= [ 2/25] Create Users                              =" >> /tmp/install.log'

rm -r /var/spool/cron/root
cp /tmp/ks/cron/root /var/spool/cron/.
chown root:root /var/spool/cron/root
chmod 600 /var/spool/cron/root
sh -c 'echo "= [ 3/25] Set Cronjobs                              =" >> /tmp/install.log'

yum -y install epel-release
yum -y groupinstall X11
yum -y groups install "Xfce"
systemctl set-default graphical.target
echo "exec /usr/bin/xfce4-session" >> ~/.xinitrc
rm -f /usr/share/xsessions/openbox.desktop
#Hide ncriadmin from GDM login
cp -r /tmp/ks/hideuser/. /var/lib/AccountsService/users/.
sh -c 'echo "= [ 4/25] Installed XFCE4 & Set GUI                 =" >> /tmp/install.log'

#Install Packages
#FortiClient Online Method
#wget -O /tmp/ks/forticlient.rpm https://links.fortinet.com/forticlient/rhel/vpnagent
#yum -y install /tmp/ks/forticlient.rpm
#Offline Method Install
yum -y install /tmp/ks/forti/forticlient_vpn_7.0.0.0018_x86_64.rpm
#Other Packages
yum -y install remmina gnome-system-monitor pulseaudio-utils alsa-tools fail2ban tmux
#Install speedtest-cli
wget -P /usr/local/bin/ https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
sh -c 'echo "= [ 5/25] Installed Packages                        =" >> /tmp/install.log'

#Restore xfce4 Panels
rm -rf /root/.config/xfce4/
rm -rf /home/"$username1"/.config/xfce4/
mkdir -p /root/.config/
mkdir -p /home/"$username1"/.config/
cp -r /tmp/ks/xfce4/ /root/.config/.
cp -r /tmp/ks/xfce4/ /home/"$username1"/.config/.
sh -c 'echo "= [ 6/25] Restore XFCE4 Panels                      =" >> /tmp/install.log'
#Add PulseAudio Defaults
cp -r /tmp/ks/pulse/ /etc/.
sh -c 'echo "= [ 7/25] Set PulseAudio Defaults                   =" >> /tmp/install.log'
#Add *.desktop files
cp -r /tmp/ks/autostart/ /home/"$username1"/.config/.
sh -c 'echo "= [ 8/25] Added autostart Files                     =" >> /tmp/install.log'
#Add /usr/local/bin/ Scripts
cp -r /tmp/ks/bin/ /usr/local/.
sh -c 'echo "= [ 9/25] Added scripts                             =" >> /tmp/install.log'
#Transfer Gnome Keyring Defaults
mkdir -p /home/"$username1"/.local/share/
cp -r /tmp/ks/keyrings/ /home/"$username1"/.local/share/.
sh -c 'echo "= [10/25] Added Gnome Keyring Defaults              =" >> /tmp/install.log'
#Transfer Remmina Template
cp -r /tmp/ks/remmina/ /home/"$username1"/.local/share/.
cp -r /tmp/ks/remmina/ /root/.
sh -c 'echo "= [11/25] Set Remmina Template                      =" >> /tmp/install.log'
#Set Wallpaper
mkdir -p /usr/share/backgrounds/images/
cp -r /tmp/ks/default.png /usr/share/backgrounds/images/default.png
sh -c 'echo "= [12/25] Set Wallpaper                             =" >> /tmp/install.log'
#Kiosk Mode
cp -r /home/"$username1"/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
sed -i 's/<channel name="xfce4-panel" version="1.0">/<channel name="xfce4-panel" version="1.0" locked="*" unlocked="tmp">/g' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
sh -c 'echo "= [13/25] Set Kiosk Mode                            =" >> /tmp/install.log'
#Add FortiClient database file
rm -r /etc/forticlient/config.db
cp /tmp/ks/forti/config.db /etc/forticlient/.
chown root:root /etc/forticlient/config.db
chmod 600 /etc/forticlient/config.db
#FortiClient DNS Issue
cp -r /etc/sysconfig/network-scripts/ifcfg-e* /root/.
cp -r /etc/sysconfig/network-scripts/ifcfg-l* /root/.
sh -c 'echo "= [14/25] Configured FortiClient                    =" >> /tmp/install.log'
#Add public sshkeys
mkdir /home/"$username2"/.ssh
cp -r /tmp/ks/ssh/. /home/"$username2"/.ssh/.
sh -c 'echo "= [15/25] Added public sshkeys                      =" >> /tmp/install.log'
#Enabled Fail2Ban
cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
systemctl enable fail2ban
#Enabled firewalld
systemctl unmask firewalld
systemctl start firewalld
systemctl enable firewalld
#x11vnc port
firewall-cmd --permanent --zone=public --add-port=5900/tcp
sh -c 'echo "= [16/25] Enabled firewalld & fail2ban              =" >> /tmp/install.log'
#Install x11vnc
yum -y install x11vnc
x11vnc -storepasswd "$(echo U2FsdGVkX19rLA9jbJQObDRL9qoMwfhkIFtiWBkSYzA= | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:'password')" /etc/x11vnc.pwd
cp -r /tmp/ks/x11vnc/x11vnc.service /etc/systemd/system/.
sh -c 'echo "= [17/25] Installed x11vnc                          =" >> /tmp/install.log'
mkdir /home/ncriadmin/logs
sh -c 'echo "= [18/25] Added Network Test Logs                   =" >> /tmp/install.log'
#Disable IPv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p
#Disable IPv6 Kernel
sed -i 's/GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet"/GRUB_CMDLINE_LINUX="ipv6.disable=1 crashkernel=auto rhgb quiet"/g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
sh -c 'echo "= [19/25] Disabled IPv6                             =" >> /tmp/install.log'
#Appdata Permissions
#Install Flatpak packages
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.microsoft.Teams
flatpak install -y flathub us.zoom.Zoom
sed -i 's/filesystems=xdg-download;/filesystems=/g' /var/lib/flatpak/app/com.microsoft.Teams/x86_64/stable/b06304204e91071deb93fd186b47f6b5e0d6c059aa8a30300e7f67be804c566c/metadata
sed -i 's/filesystems=~\/Documents\/Zoom:create;~\/.zoom:create;/filesystems=/g' /var/lib/flatpak/app/us.zoom.Zoom/current/active/metadata
sh -c 'echo "= [20/25] Added Flatpak Packages                    =" >> /tmp/install.log'

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
sh -c 'echo "= [21/25] Set Permissions                           =" >> /tmp/install.log'

#Update CentOS
yum -y update
sh -c 'echo "= [22/25] Update CentOS                             =" >> /tmp/install.log'

#Upgrade to Elrepo Kernel LT
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install -y kernel-lt
sed -i 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/g' /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sh -c 'echo "= [23/25] Update Kernel                             =" >> /tmp/install.log'

touch /home/ncriadmin/version
sh -c 'echo "Version 1.4" >> /home/ncriadmin/version'
sh -c 'echo "= [24/25] Versioning                                =" >> /tmp/install.log'

#Cleanup
rm -rf /tmp/ks/
sh -c 'echo "= [25/25] Cleanup and Reboot                        =" >> /tmp/install.log'
sh -c 'echo "=====================================================" >> /tmp/install.log'
cp /tmp/install.log /home/ncriadmin/.
sudo reboot
reboot