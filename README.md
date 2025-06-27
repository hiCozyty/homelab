# Homelab 

## Requirements
- 1 dedicated PC to run RHEL host
- 1 USB to Ethernet NIC (2.5Gbps or higher)
- Wireless router for local network devices 

## Setup requirements
1. USB NIC = **WAN input** from ISP 
  -> this goes **to pfSense VM only** (via passthrough)
  
2. Motherboard NIC = **LAN output** 
   -> this connects to home router/AP

3. pfSense runs inside a VM, **acts as the firewall/router**

4. RHEL host **should not** access the internet directly via USB NIC

## Architecture Overview
...

## Setting up Virtualization in RHEL

```
sudo dnf install qemu-kvm libvirt virt-install
```
```
sudo dnf install cockpit
```
setup cockpit
```
sudo firewall-cmd --add-port=9090/tcp
sudo firewall-cmd --permanent --add-port=9090/tcp
sudo systemctl enable cockpit.socket
sudo systemctl start cockpit.socket
```

get the name of the usb-nic

```
ip -br a | grep '\/' | awk '{print $1|'
```

for me: `enp5s0f4u2u2`

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

## Setup pfSense VM via cockpit

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
