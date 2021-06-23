#!/bin/bash
#Nam - 20210623
#Disables internal PCI cards PulseAudio
if [[$(pacmd list-cards | egrep "alsa_card.pci" | cut -d"<" -f2 | cut -d">" -f1 | sed -n 1p)]]; then
    card1=$(pacmd list-cards | egrep "alsa_card.pci" | cut -d"<" -f2 | cut -d">" -f1 | sed -n 1p)
    sleep 2
    pacmd set-card-profile $card1 off
fi
if [[$(pacmd list-cards | egrep "alsa_card.pci" | cut -d"<" -f2 | cut -d">" -f1 | sed -n 2p)]]; then
    card2=$(pacmd list-cards | egrep "alsa_card.pci" | cut -d"<" -f2 | cut -d">" -f1 | sed -n 2p)
    sleep 2
    pacmd set-card-profile $card2 off
fi
if [[$(pacmd list-cards | egrep "alsa_card.pci" | cut -d"<" -f2 | cut -d">" -f1 | sed -n 3p)]]; then
    card3=$(pacmd list-cards | egrep "alsa_card.pci" | cut -d"<" -f2 | cut -d">" -f1 | sed -n 3p)
    sleep 2
    pacmd set-card-profile $card3 off
fi