#!/bin/bash
#Nam - 20210809
#Resets remmina configuration on reboot
username1="Agent"

rm -rf /home/"$username1"/.local/share/remmina/
cp -r /root/remmina/ /home/"$username1"/.local/share/.
chown "$username1":"$username1" -R /home/"$username1"/.local/share/remmina