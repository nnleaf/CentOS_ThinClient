#!/bin/bash
#Nam - 20210917
#Hotel Build
echo "====================================================="
echo "=                 _  _  ___ ___ ___                 ="
echo "=                | \| |/ __| _ \_ _|                ="
echo "=                |    | (__|   /| |                 ="
echo "=                |_|\_|\___|_|_\___|                ="
echo "=                                                   ="
echo "====================================================="
echo " "
read -p "Enter your VM name, then press [ENTER] : " input
sed -i "/server=/d" /home/Agent/.local/share/remmina/corp-ncri-com.remmina
echo server=${input}.CORP.NCRI.COM >> /home/Agent/.local/share/remmina/corp-ncri-com.remmina
killall remmina
killall xfce4-terminal