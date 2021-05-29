#!/bin/bash
#Nam - 20210528
#Resets NetworkManager to default settings on every boot
/bin/cp -rf /root/nm/ifcfg-ens33 /etc/sysconfig/network-scripts/.
/bin/cp -rf /root/nm/ifcfg-lo /etc/sysconfig/network-scripts/.
systemctl restart network