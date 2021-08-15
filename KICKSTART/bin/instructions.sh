#!/bin/bash
#Nam - 20210813
#Admin Instructions
cat /tmp/script_log.log
echo "====================================================="
echo "=================== Build Details ==================="
echo "====================================================="
echo "=                    Version 1.0                    ="
echo "=             Released 2021.08.15 - Nam             ="
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
rm -rf /home/Agent/.config/autostart/instructions.desktop
sudo reboot