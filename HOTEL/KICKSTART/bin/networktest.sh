#!/bin/bash
#Nam - 20210928
#Runs network testing to a log file

echo -n > /home/ncriadmin/logs/temp_log1.log

#Get VM Name
echo "==========================================================================================================" >> /home/ncriadmin/logs/temp_log1.log
echo "==                                              Information                                             ==" >> /home/ncriadmin/logs/temp_log1.log
echo "==========================================================================================================" >> /home/ncriadmin/logs/temp_log1.log
#VM Name
vmname=$(grep -h "CORP.NCRI.COM" /home/Agent/.local/share/remmina/corp-ncri-com.remmina)
echo $vmname >> /home/ncriadmin/logs/temp_log1.log
#Date
echo $(date +%Y-%m-%d_%H%M%S) >> /home/ncriadmin/logs/temp_log1.log
sed 's/server=//' /home/ncriadmin/logs/temp_log1.log >> /home/ncriadmin/logs/temp_log.log
#Get IP Address
echo "Ip Address" >> /home/ncriadmin/logs/temp_log.log
ip addr >> /home/ncriadmin/logs/ip_temp.txt
ipaddress=$(grep -h "global vpn" /home/ncriadmin/logs/ip_temp.txt)
echo $ipaddress >> /home/ncriadmin/logs/temp_log.log
echo "==========================================================================================================" >> /home/ncriadmin/logs/temp_log.log
echo "==                                             Network Test                                             ==" >> /home/ncriadmin/logs/temp_log.log
echo "==========================================================================================================" >> /home/ncriadmin/logs/temp_log.log
#Speedtest
echo "== Speedtest ==" >> /home/ncriadmin/logs/temp_log.log
python /usr/local/bin/speedtest.py >> /home/ncriadmin/logs/temp_log.log
#MTR
echo "== Ping and Jitter Test - NCRI ==" >> /home/ncriadmin/logs/temp_log.log
sudo mtr -r -n -i 0.1 -c 50 -o "L BAWV MI" corp.ncri.com >> /home/ncriadmin/logs/temp_log.log
echo "== Ping and Jitter Test - Google ==" >> /home/ncriadmin/logs/temp_log.log
sudo mtr -r -n -i 0.1 -c 50 -o "L BAWV MI" google.ca >> /home/ncriadmin/logs/temp_log.log

#cleanup
cp /home/ncriadmin/logs/temp_log.log /home/ncriadmin/logs/temp_log_"$(date +%Y-%m-%d_%H%M%S)".log
rm /home/ncriadmin/logs/ip_temp.txt /home/ncriadmin/logs/temp_log.log /home/ncriadmin/logs/temp_log1.log