#!/bin/bash
#Nam - 20210928
#Network Tests

echo -n > /home/Agent/logs/temp_log1.log

#Get VM Name
echo "==========================================================================================================" >> /home/Agent/logs/temp_log1.log
echo "==                                               VM Name                                                ==" >> /home/Agent/logs/temp_log1.log
echo "==========================================================================================================" >> /home/Agent/logs/temp_log1.log
vmname=$(grep -h "CORP.NCRI.COM" /home/Agent/.local/share/remmina/corp-ncri-com.remmina)
echo $vmname >> /home/Agent/logs/temp_log1.log
sed 's/server=//' /home/Agent/logs/temp_log1.log >> /home/Agent/logs/temp_log.log
#Get IP Address
echo "Ip Address" >> /home/Agent/logs/temp_log.log
ip addr >> /home/Agent/logs/ip_temp.txt
ipaddress=$(grep -h "global vpn" /home/Agent/logs/ip_temp.txt)
echo $ipaddress >> /home/Agent/logs/temp_log.log
echo "Speedtest" >> /home/Agent/logs/temp_log.log
python /usr/local/bin/speedtest-cli >> /home/Agent/logs/temp_log.log
echo "Ping and Jitter Test" >> /home/Agent/logs/temp_log.log
sudo mtr -r -n -i 0.1 -c 50 -o "L BAWV MI" corp.ncri.com >> /home/Agent/logs/temp_log.log



#cleanup
#cp /home/Agent/logs/temp_log.log /home/Agent/logs/temp_log_"$(date +%Y-%m-%d_%H%M%S)".log
rm /home/Agent/logs/ip_temp.txt /home/Agent/logs/temp_log1.log