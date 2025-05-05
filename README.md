# Homelab 
## Introduction
...

## Requirements
- At least 2 PCs
- 1 USB to Ethernet NIC
- Wireless router for local network devices (phones, PC2, TV, etc)
- Fedora workstation installed on PC1

## Architecture Overview
...

## Install Fedora Workstation on PC1

Download fedora workstation from `https://fedoraproject.org/workstation/` and install
Update system
```
sudo dnf update -y
```
Install virt packages, start services
```
sudo dnf install @virtualization
sudo systemctl enable --now libvirtd
```

## Install tailscale into Fedora Host
...

## Setup network bridge (br0)

Remove default virtual network
```
sudo virsh net-destroy default
sudo virsh net-autostart --disable default
sudo virsh net-undefine default
```
Create the new bridge connection and configure DHCP
```
sudo nmcli connection add type bridge autoconnect yes con-name br0 ifname br0
sudo nmcli connection modify br0 ipv4.method auto
```
Add the regular NIC (from the motherboard) as a slave to the bridge 
IMPORTANT: change enp3s0 to the correct NIC name
```
sudo nmcli connection add type ethernet slave-type bridge con-name br0-port1 ifname enp3s0 master br0
```
Bring up the Bridge and NIC
```
sudo nmcli connection up br0
sudo nmcli connection up br0-port1
```
Restart to apply changes
```
sudo systemctl restart NetworkManager
```

## Install cockpit 
```
sudo dnf install cockpit cockpit-machines -y
sudo systemctl enable --now cockpit.socket
```

## Install pfSense
Download the pfSense CE from `https://www.pfsense.org/download/`


## Install tailscal inside pfSense
...

## Disable DHCP autoconnect for the usb-eth nic
ensure WAN traffic only go thru pfSense and not get routed to the host when pfSense VM crashes or turns off.
IMPORTANT: change `enp5s0f4u1` to the correct USB-Ethernet nic name

```
sudo tee /etc/NetworkManager/conf.d/10-unmanaged-enp5s0f4u1.conf > /dev/null <<EOF
[keyfile]
unmanaged-devices=interface-name:enp5s0f4u1
EOF

sudo systemctl restart NetworkManager
```
