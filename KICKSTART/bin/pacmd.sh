#!/bin/bash
#Nam - 20210521
#Sets Volume for PulseAudio
INDEX=$(pacmd list-sources | egrep 'index|ports|analog-input-headset-mic' | egrep '\*\sindex:\s+[0-9]'  | cut -d':' -f2)

sleep 3 && /usr/bin/pacmd set-sink-volume 0 65538
sleep 3 && /usr/bin/pacmd set-sink-mute 0 0
sleep 3 && /usr/bin/pacmd set-sink-volume "$INDEX" 65538
sleep 3 && /usr/bin/pacmd set-sink-mute "$INDEX" 0