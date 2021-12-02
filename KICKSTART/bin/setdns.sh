#!/bin/bash
#Nam - 20210528
#Resets NetworkManager to default settings on every boot
rm -rf /etc/sysconfig/network-scripts/ifcfg-*
rm /etc/resolv.conf
/bin/cp -rf /root/ifcfg-e* /etc/sysconfig/network-scripts/.
/bin/cp -rf /root/ifcfg-l* /etc/sysconfig/network-scripts/.
systemctl restart network
#XFCE-Panel Disappearing Issue
rm -rf ~/.cache/sessions