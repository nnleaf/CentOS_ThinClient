#!/bin/bash
#Nam - 20210809
#Resets remmina configuration on reboot
username="Agent"

rm -rf /home/"$username"/.local/share/remmina/
cp -r /root/remmina/ /home/"$username"/.local/share/.