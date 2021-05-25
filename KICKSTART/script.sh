#!/bin/bash
#
#Nam - 20210513
#Thinclient Installation Script after Kickstart

/usr/sbin/useradd -m Client
/usr/bin/echo "Client:user123" | /usr/sbin/chpasswd
#echo "user123" | passwd Client

#Enable ethernet
sed -i '/ONBOOT="no"/d' /etc/sysconfig/network-scripts/ifcfg-e*
sed -i '/ONBOOT=no/d' /etc/sysconfig/network-scripts/ifcfg-e*
sed -i '/ONBOOT="YES"/d' /etc/sysconfig/network-scripts/ifcfg-e*
sed -i '/ONBOOT=yes/d' /etc/sysconfig/network-scripts/ifcfg-e*
echo "ONBOOT=YES" >> /etc/sysconfig/network-scripts/ifcfg-e*
systemctl restart network

#Install xfce
yum -y install epel-release
yum -y groupinstall X11
yum -y groups install "Xfce"
#systemctl set-default graphical.target
ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target
echo "exec /usr/bin/xfce4-session" >> ~/.xinitrc
rm -f /usr/share/xsessions/openbox.desktop

#Install Programs
mkdir -p /root/temp
wget -O /root/temp/google-chrome.rpm https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
wget -O /root/temp/teams.rpm https://packages.microsoft.com/yumrepos/ms-teams/teams-1.3.00.25560-1.x86_64.rpm
#wget -O /root/temp/fortigate.rpm https://links.fortinet.com/forticlient/rhel/vpnagent
mv /root/forticlient.rpm /root/temp/forticlient.rpm
yum -y install /root/temp/teams.rpm
yum -y install /root/temp/google-chrome.rpm
yum -y install /root/temp/forticlient.rpm
#yum -y install /root/temp/fortigate.rpm
yum -y install firefox
yum -y install remmina

#Restore xfce4 panels
rm -rf /root/.config/xfce4/panel
rm -rf /root/.config/xfce4/xfconf
rm -rf /home/Client/.config/xfce4/panel
rm -rf /home/Client/.config/xfce4/xfconf
mkdir -p /root/.config/xfce4
mkdir -p /home/Client/.config/xfce4
cp -r /root/xfce4/panel /root/.config/xfce4/panel
cp -r /root/xfce4/xfconf /root/.config/xfce4/xfconf
cp -r /root/xfce4/panel /home/Client/.config/xfce4/panel
cp -r /root/xfce4/xfconf /home/Client/.config/xfce4/xfconf
#Give ownership to created user
chown -R Client:Client /home/Client

#Update CentOS
#yum -y update

#Cleanup
rm -rf /root/temp
rm -rf /root/xfce4
sed -i '$d' /var/spool/cron/root
rm -f /root/script.sh
sudo reboot