#!/bin/bash
#Nam - 20210528
#Starts systemctl for x11vnc
systemctl daemon-reload
systemctl enable x11vnc
systemctl start x11vnc
rm -rf /usr/local/bin/x11vnc.sh
sudo sed -i '$d' /var/spool/cron/root