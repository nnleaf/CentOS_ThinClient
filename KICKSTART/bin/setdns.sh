#!/bin/bash
#Nam - 20210528
#Resets NetworkManager to default settings on every boot
rm -rf /etc/sysconfig/network-scripts/
/bin/cp -rf /root/network-scripts/ /etc/sysconfig/.
systemctl restart network