#!/bin/bash
#Nam - 20211129
#Disables IPv6 

echo "====================================================="
echo "======================= UPDATE ======================"
echo "====================================================="
echo "=        Version 1.3 > 1.4 Disable IPv6             ="
echo "=                Released 2021.11.29                ="
echo "====================================================="
echo "====================================================="
echo " "
cat /home/ncriadmin/version
echo " "
echo "--[ Only use this update if version is 1.3, run update? (y/n) ]--"
read -p ""
if [[ $REPLY =~ ^[Yy]$ ]] 
then
  #Disable IPv6
  echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
  echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
  sysctl -p
  #Disable IPv6 Kernel
  sed -i 's/GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet"/GRUB_CMDLINE_LINUX="ipv6.disable=1 crashkernel=auto rhgb quiet"/g' /etc/default/grub
  grub2-mkconfig -o /boot/grub2/grub.cfg
fi
#Versioning Change
sed -i '/Version 1.3/c\Version 1.4' /home/ncriadmin/version
#Cleanup
rm -r /tmp/update_1_4
#Confirmation
echo " "
echo "--[ Confirmation - If all values are 1, IPv6 is disabled ]--"
echo " "
sysctl -a 2>/dev/null | grep disable_ipv6
ip addr show | grep net6
echo "--[ Ready to Reboot? (y/n) ]--"
read -p ""
if [[ $REPLY =~ ^[Yy]$ ]] 
then
  reboot -h now
fi