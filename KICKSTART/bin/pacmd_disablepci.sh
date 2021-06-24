#!/bin/bash
#Nam - 20210623
#Disables internal PCI cards PulseAudio
card1=$(pacmd list-cards | egrep "alsa_card.pci" | cut -d"<" -f2 | cut -d">" -f1 | sed -n 1p)
card2=$(pacmd list-cards | egrep "alsa_card.pci" | cut -d"<" -f2 | cut -d">" -f1 | sed -n 2p)
card3=$(pacmd list-cards | egrep "alsa_card.pci" | cut -d"<" -f2 | cut -d">" -f1 | sed -n 3p)
sleep2
pacmd set-card-profile $card1 off
sleep2
pacmd set-card-profile $card2 off
sleep2
pacmd set-card-profile $card3 off