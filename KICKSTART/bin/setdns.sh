#!/bin/bash
#Nam - 20210528
#Resets NetworkManager to default settings on every boot
rm -rf /etc/sysconfig/network-scripts/ifcfg-e*
rm /etc/resolv.conf
/bin/cp -rf /root/ifcfg-e* /etc/sysconfig/network-scripts/.
systemctl restart network