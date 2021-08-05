# CentOS ThinClient

## Introduction

My first project at NCRi, I was tasked with developing an efficient method to deploy CentOS Thin Clients for our staff of 300+ employees. Due to growing business needs, new compliance guidelines required all data to stay on our secure servers. This meant that staff were required to remote into Windows VM's through a FortiGate VPN. 

I utilized Kickstart to perform an agnostic and automated CentOS installation, which then started a BASH script to install and setup the final configuration. By heavily optimizing CentOS for low-end hardware, it had the effect of saving the company thousands of dollars buying hardware for each staff member and the windows licencing cost.

## Instructions

You will need two USB flash drives, one flashed with CentOS ISO and the other with the files in the KICKSTART folder

1. Make sure boot is set to HDD in BIOS
2. Boot from CentOS ISO USB
3. Press 'esc' and start kickstart script

`linux ks=hd:UUID=[UUID NUMBER]:/ks.cfg`

4. Sit back

## Details

2021.05.21 - pacmd.sh - Set volume to 100% volume & unmute on boot<br/>
2021.05.22 - [Set PulseAudio to always change device to recent plugged in](https://doc.nnserver.ca/books/general-centos/page/pulseaudio)<br/>
2021.05.28 - setdns.sh - [FortiClient has an issue with DNS not reverting if disconnect not performed gracefully. Set script to copy NetworkManager defaults to /root and copy over settings on every reboot](https://doc.nnserver.ca/books/general-centos/page/forticlient-dns-issue)<br/>
2021.06.02 - Added logging information and a terminal screen popup at first login for admin configuration<br/>
2021.06.03 - dos2unix<br/>
2021.07.14 - Added IPv4 precedence, Disables PCI sound devices, changes to FortiClient DNS issue<br/>

## Links

[CentOS Documentation](https://doc.nnserver.ca/books/general-centos?shelf=11)