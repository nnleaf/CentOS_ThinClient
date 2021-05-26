# CentOS_ThinClient
 CentOS ThinClient NCRI

My first project at NCRi, I was tasked with developing an efficient method to deploy CentOS Thin Clients for our staff of 300+ employees. Due to growing business needs, new compliance guidelines required all data to stay on our secure servers. This meant that staff were required to remote into Windows VM's through a FortiGate VPN. 

I utilized Kickstart to perform an agnostic and automated CentOS installation, which then started a BASH script to install and setup the final configuration. By heavily optimizing CentOS for low-end hardware, it also had the effect of saving the company thousands of dollars buying powerful computers for each staff member. 
