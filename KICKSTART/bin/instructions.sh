#!/bin/bash
#Nam - 20210813
#Admin Instructions
cat /tmp/install.log
echo "====================================================="
echo "=                 _  _  ___ ___ ___                 ="
echo "=                | \| |/ __| _ \_ _|                ="
echo "=                |    | (__|   /| |                 ="
echo "=                |_|\_|\___|_|_\___|                ="
echo "=                                                   ="
echo "====================================================="
echo "=================== Build Details ==================="
echo "====================================================="
echo "=                    Version 1.5                    ="
echo "=                Released 2022.03.18                ="
echo "=             `sudo dmidecode -t system | grep Product`            ="
echo "=              `sudo dmidecode -t system | grep Serial`             ="
echo "====================================================="
echo "========= Set FortiClient VPN Configuration ========="
echo "====================================================="
echo "=            Connection Name - NCRI_VPN             ="
echo "=              Description - NCRI_VPN               ="
echo "=         Remote Gateway - TORSEC1.NCRI.COM         ="        
echo "=              Customize Port - 8443                ="
echo "====================================================="
echo "============== Set Remote Desktop Name =============="
echo "====================================================="
read -p "Enter the RDP name, then press [ENTER] : " input
sed -i "s/server=/server=${input}.CORP.NCRI.COM/g" /root/remmina/corp-ncri-com.remmina
#Disables ALT+F2, ALT+F3
rm -rf /home/Agent/.config/autostart/instructions.desktop /home/Agent/.config/autostart/disable_shortcut_1.desktop /home/Agent/.config/autostart/disable_shortcut_2.desktop /home/Agent/.config/autostart/forticlient.desktop
sudo reboot