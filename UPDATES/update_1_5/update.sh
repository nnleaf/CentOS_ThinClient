#!/bin/bash
#Nam - 20220317
#Updates from 1.4 > 1.5
#Adds new resetrdp script and remmina config files

echo "====================================================="
echo "======================= UPDATE ======================"
echo "====================================================="
echo "=   Version 1.4 > 1.5 Remmina & Neofetch Updates    ="
echo "=                Released 2022.03.18                ="
echo "====================================================="
echo "====================================================="
echo " "

#Variables 
username1="Agent"
username2="ncriadmin"

cat /home/ncriadmin/version
echo " "
echo "--[ Only use this update if version is 1.4, run update? (y/n) ]--"
read -p ""
if [[ $REPLY =~ ^[Yy]$ ]] 
then
  #Update yum
  yum -y update
  #Update GRUB to remove menu choices
  sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
  echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub
  grub2-mkconfig -o /boot/grub2/grub.cfg
  #Update Remmina
  yum -y install remmina
  #Copy new resetrdp.sh
  rm -rf /usr/local/bin/resetrdp.sh
  cp -r /tmp/update_1_5/bin/resetrdp.sh /usr/local/bin/.
  #Transfer Remmina Preferences File
  rm -rf /home/"$username1"/.config/remmina/
  mkdir -p /home/"$username1"/.config/remmina/
  cp -r /tmp/update_1_5/remmina/remmina.pref /home/"$username1"/.config/remmina/.
  chown "$username1":"$username1" -R /home/"$username1"/.config/remmina/
  #Transfer Remmina Configuration File to root and Agent
  rm -rf /home/"$username1"/.local/share/remmina/
  rm -rf /root/remmina/
  mkdir -p /home/"$username1"/.local/share/remmina/
  mkdir -p /root/remmina/
  cp -r /tmp/update_1_5/remmina/corp-ncri-com.remmina /home/"$username1"/.local/share/remmina/.
  cp -r /tmp/update_1_5/remmina/corp-ncri-com.remmina rm -rf /root/remmina/.
  chown "$username1":"$username1" -R /home/"$username1"/.local/share/remmina/
  #Install Neofetch
  yum -y localinstall /tmp/update_1_5/neofetch/neofetch-6.1.0-1.el7.noarch.rpm
  #Set Neofetch configuration
  echo "neofetch" >> /etc/bashrc
  rm -r /home/"$username1"/.config/neofetch/
  mkdir -p /home/"$username1"/.config/neofetch/
  rm -r /home/"$username2"/.config/neofetch/
  mkdir -p /home/"$username2"/.config/neofetch/
  cp -r /tmp/update_1_5/neofetch/config.conf /home/"$username1"/.config/neofetch/config.conf
  cp -r /tmp/update_1_5/neofetch/config.conf /home/"$username2"/.config/neofetch/config.conf
fi
#Versioning Change
sed -i '/Version 1.4/c\Version 1.5' /home/ncriadmin/version
#Cleanup
rm -r /tmp/update_1_5
echo "--[ Ready to Reboot? (y/n) ]--"
read -p ""
if [[ $REPLY =~ ^[Yy]$ ]] 
then
  reboot -h now
fi