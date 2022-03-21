#!/bin/bash
#Nam - 20210513
#Thinclient Installation Script after Kickstart

#Create Logging File
#Any updates will need the versioning changed here, in /bin/instructions.sh, and [24/26] Versioning
touch /tmp/install.log
sh -c 'echo "=====================================================" >> /tmp/install.log'
sh -c 'echo "=================== Build Details ===================" >> /tmp/install.log'
sh -c 'echo "=====================================================" >> /tmp/install.log'
sh -c 'echo "=                    Version 1.5                    =" >> /tmp/install.log'
sh -c 'echo "=                Released 2022.03.18                =" >> /tmp/install.log'
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
sh -c 'echo "= [ 1/26] Ethernet & WiFi Enabled                   =" >> /tmp/install.log'

#Create User1 Account
/usr/sbin/useradd -m $username1
passwd -d $username1
#Create User2 Account
yum -y install sshpass
/usr/sbin/useradd -m $username2
(echo U2FsdGVkX1+IPWbhHzXcfKcvxgIym9LhfoEgihwOMB+YX979Q01D3YQm/MUap3GB | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:'password'; echo U2FsdGVkX1+IPWbhHzXcfKcvxgIym9LhfoEgihwOMB+YX979Q01D3YQm/MUap3GB | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:'password') | passwd $username2
sh -c 'echo "= [ 2/26] Create Users                              =" >> /tmp/install.log'

rm -r /var/spool/cron/root
cp /tmp/ks/cron/root /var/spool/cron/.
chown root:root /var/spool/cron/root
chmod 600 /var/spool/cron/root
sh -c 'echo "= [ 3/26] Set Cronjobs                              =" >> /tmp/install.log'

yum -y install epel-release
yum -y groupinstall X11
yum -y groups install "Xfce"
systemctl set-default graphical.target
echo "exec /usr/bin/xfce4-session" >> ~/.xinitrc
rm -f /usr/share/xsessions/openbox.desktop
#Hide ncriadmin from GDM login
cp -r /tmp/ks/hideuser/. /var/lib/AccountsService/users/.
sh -c 'echo "= [ 4/26] Installed XFCE4 & Set GUI                 =" >> /tmp/install.log'

#Install Packages
#FortiClient Online Method
#wget -O /tmp/ks/forticlient.rpm https://links.fortinet.com/forticlient/rhel/vpnagent
#yum -y install /tmp/ks/forticlient.rpm
#Offline Method Install
yum -y install /tmp/ks/forti/forticlient_vpn_7.0.0.0018_x86_64.rpm
#Other Packages
yum -y install remmina gnome-system-monitor pulseaudio-utils alsa-tools fail2ban tmux dnf-plugins-core
#Install speedtest-cli
wget -P /usr/local/bin/ https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
sh -c 'echo "= [ 5/26] Installed Packages                        =" >> /tmp/install.log'

#Restore xfce4 Panels
rm -rf /root/.config/xfce4/
rm -rf /home/"$username1"/.config/xfce4/
mkdir -p /root/.config/
mkdir -p /home/"$username1"/.config/
cp -r /tmp/ks/xfce4/ /root/.config/.
cp -r /tmp/ks/xfce4/ /home/"$username1"/.config/.
sh -c 'echo "= [ 6/26] Restore XFCE4 Panels                      =" >> /tmp/install.log'
#Add PulseAudio Defaults
cp -r /tmp/ks/pulse/ /etc/.
sh -c 'echo "= [ 7/26] Set PulseAudio Defaults                   =" >> /tmp/install.log'
#Add *.desktop files
cp -r /tmp/ks/autostart/ /home/"$username1"/.config/.
sh -c 'echo "= [ 8/26] Added autostart Files                     =" >> /tmp/install.log'
#Add /usr/local/bin/ Scripts
cp -r /tmp/ks/bin/ /usr/local/.
sh -c 'echo "= [ 9/26] Added scripts                             =" >> /tmp/install.log'
#Transfer Gnome Keyring Defaults
mkdir -p /home/"$username1"/.local/share/
cp -r /tmp/ks/keyrings/ /home/"$username1"/.local/share/.
sh -c 'echo "= [10/26] Added Gnome Keyring Defaults              =" >> /tmp/install.log'
#Transfer Remmina Preferences File
mkdir -p /home/"$username1"/.config/remmina/
cp -r /tmp/ks/remmina_preferences/remmina.pref /home/"$username1"/.config/remmina/.
#Transfer Remmina Configuration File
cp -r /tmp/ks/remmina/ /root/.
cp -r /tmp/ks/remmina/ /home/"$username1"/.local/share/.
sh -c 'echo "= [11/26] Set Remmina Configuration & Preferences   =" >> /tmp/install.log'
#Set Wallpaper
mkdir -p /usr/share/backgrounds/images/
cp -r /tmp/ks/default.png /usr/share/backgrounds/images/default.png
sh -c 'echo "= [12/26] Set Wallpaper                             =" >> /tmp/install.log'
#Kiosk Mode
cp -r /home/"$username1"/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
sed -i 's/<channel name="xfce4-panel" version="1.0">/<channel name="xfce4-panel" version="1.0" locked="*" unlocked="tmp">/g' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
sh -c 'echo "= [13/26] Set Kiosk Mode                            =" >> /tmp/install.log'
#Add FortiClient database file
rm -r /etc/forticlient/config.db
cp /tmp/ks/forti/config.db /etc/forticlient/.
chown root:root /etc/forticlient/config.db
chmod 600 /etc/forticlient/config.db
#FortiClient DNS Issue
cp -r /etc/sysconfig/network-scripts/ifcfg-e* /root/.
cp -r /etc/sysconfig/network-scripts/ifcfg-l* /root/.
sh -c 'echo "= [14/26] Configured FortiClient                    =" >> /tmp/install.log'
#Add public sshkeys
mkdir /home/"$username2"/.ssh
cp -r /tmp/ks/ssh/. /home/"$username2"/.ssh/.
sh -c 'echo "= [15/26] Added public sshkeys                      =" >> /tmp/install.log'
#Enabled Fail2Ban
cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
systemctl enable fail2ban
#Enabled firewalld
systemctl unmask firewalld
systemctl start firewalld
systemctl enable firewalld
#x11vnc port
firewall-cmd --permanent --zone=public --add-port=5900/tcp
sh -c 'echo "= [16/26] Enabled firewalld & fail2ban              =" >> /tmp/install.log'
#Install x11vnc
yum -y install x11vnc
x11vnc -storepasswd "$(echo U2FsdGVkX19rLA9jbJQObDRL9qoMwfhkIFtiWBkSYzA= | openssl enc -aes-256-cbc -md sha512 -a -d -salt -pass pass:'password')" /etc/x11vnc.pwd
cp -r /tmp/ks/x11vnc/x11vnc.service /etc/systemd/system/.
sh -c 'echo "= [17/26] Installed x11vnc                          =" >> /tmp/install.log'
mkdir /home/ncriadmin/logs
sh -c 'echo "= [18/26] Added Network Test Logs                   =" >> /tmp/install.log'
#Disable IPv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p
#Disable IPv6 Kernel & Disable GRUB menu on boot
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet"/GRUB_CMDLINE_LINUX="ipv6.disable=1 crashkernel=auto rhgb quiet"/g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
sh -c 'echo "= [19/26] Disabled IPv6                             =" >> /tmp/install.log'
#Install Neofetch
sudo yum -y install /tmp/ks/neofetch/neofetch-6.1.0-1.el7.noarch.rpm
#Set Neofetch configuration
echo "neofetch" >> /etc/bashrc
rm -r /home/"$username1"/.config/neofetch/
mkdir -p /home/"$username1"/.config/neofetch/
rm -r /home/"$username2"/.config/neofetch/
mkdir -p /home/"$username2"/.config/neofetch/
cp -r /tmp/ks/neofetch/config.conf /home/"$username1"/.config/neofetch/config.conf
cp -r /tmp/ks/neofetch/config.conf /home/"$username2"/.config/neofetch/config.conf
sh -c 'echo "= [20/26] Install Neofetch                          =" >> /tmp/install.log'
#Appdata Permissions
#Install Flatpak packages
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.microsoft.Teams
flatpak install -y flathub us.zoom.Zoom
sed -i 's/filesystems=xdg-download;/filesystems=/g' /var/lib/flatpak/app/com.microsoft.Teams/x86_64/stable/b06304204e91071deb93fd186b47f6b5e0d6c059aa8a30300e7f67be804c566c/metadata
sed -i 's/filesystems=~\/Documents\/Zoom:create;~\/.zoom:create;/filesystems=/g' /var/lib/flatpak/app/us.zoom.Zoom/current/active/metadata
sh -c 'echo "= [21/26] Added Flatpak Packages                    =" >> /tmp/install.log'

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
sh -c 'echo "= [22/26] Set Permissions                           =" >> /tmp/install.log'

#Update CentOS
yum -y update
sh -c 'echo "= [23/26] Update CentOS                             =" >> /tmp/install.log'

#Upgrade to Elrepo Kernel LT
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install -y kernel-lt
sed -i 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/g' /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sh -c 'echo "= [24/26] Update Kernel                             =" >> /tmp/install.log'

touch /home/ncriadmin/version
sh -c 'echo "Version 1.5" >> /home/ncriadmin/version'
sh -c 'echo "= [25/26] Versioning                                =" >> /tmp/install.log'

#Cleanup
rm -rf /tmp/ks/
sh -c 'echo "= [26/26] Cleanup and Reboot                        =" >> /tmp/install.log'
sh -c 'echo "=====================================================" >> /tmp/install.log'
cp /tmp/install.log /home/ncriadmin/.
sudo reboot
reboot