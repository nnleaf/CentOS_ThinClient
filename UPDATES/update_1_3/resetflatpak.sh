#!/bin/bash
#Nam - 20211009
#Reset Flatpak appdata

rm -rf /home/Agent/.var/app/
killall teams
killall zoom