#!/bin/bash
#Nam - 20210813
#Update Script v.1.1 > v1.3 Teams/Zoom Build

#Variables
username1="Agent"

echo "====================================================="
echo "======================= UPDATE ======================"
echo "====================================================="
echo "=        Version 1.1 > 1.3 Teams/Zoom/Kernel        ="
echo "=                Released 2021.10.12                ="
echo "====================================================="

#Temp folder
mkdir /tmp/update/

#Update Kernel to Elrepo
yum update
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install -y kernel-lt
sed -i 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/g' /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

#Install Teams & Zoom Flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.microsoft.Teams
flatpak override com.microsoft.Teams --nofilesystem==/
#sed -i 's/filesystems=xdg-download;/filesystems=/g' /var/lib/flatpak/app/com.microsoft.Teams/x86_64/stable/b06304204e91071deb93fd186b47f6b5e0d6c059aa8a30300e7f67be804c566c/metadata
flatpak install -y flathub us.zoom.Zoom

#Add new xfce4 panels
sed -i 's/<channel name="xfce4-panel" version="1.0" locked="\*" unlocked="tmp">/<channel name="xfce4-panel" version="1.0">/g' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
rm -rf /root/.config/xfce4/
rm -rf /home/"$username1"/.config/xfce4/
mkdir -p /root/.config/
mkdir -p /home/"$username1"/.config/
cp -r /tmp/update_1_3/xfce4/ /root/.config/.
cp -r /tmp/update_1_3/xfce4/ /home/"$username1"/.config/.
cp -r /home/"$username1"/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
sed -i 's/<channel name="xfce4-panel" version="1.0">/<channel name="xfce4-panel" version="1.0" locked="*" unlocked="tmp">/g' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml

#Appdata Permissions
cp /tmp/update_1_3/resetflatpak.sh /usr/local/bin/.
sed -i 's/filesystems=xdg-download;/filesystems=/g' /var/lib/flatpak/app/com.microsoft.Teams/x86_64/stable/b06304204e91071deb93fd186b47f6b5e0d6c059aa8a30300e7f67be804c566c/metadata
sed -i 's/filesystems=~\/Documents\/Zoom:create;~\/.zoom:create;/filesystems=/g' /var/lib/flatpak/app/us.zoom.Zoom/current/active/metadata

#Set cronjobs
rm -r /var/spool/cron/root
cp /tmp/update_1_3/cron/root /var/spool/cron/.
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
firewall-cmd --permanent --zone=public --add-port=5900/tcp

#Versioning
touch /home/ncriadmin/version
sh -c 'echo "Version 1.3" >> /home/ncriadmin/version'

#Cleanup
rm -r /tmp/update/ /tmp/update_1_3

#Reboot
sudo reboot