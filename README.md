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
sudo dnf install cockpit cockpit-machines
sudo usermod -aG libvirt,kvm $USER
```

Physically connect the router/AP to the motherboard NIC

Reboot

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

Add `br0` to libvirt
```
cd ~/
sudo virsh net-autostart br0-net
#save
sudo virsh net-define br0-libvirt.xml
sudo virsh net-start br0-net
sudo virsh net-autostart br0-net
#Now libvirt knows about br0
```

## Setup pfSense VM via cockpit

Go to localhost:9090

Click Virtual Machines then Create and edit

Remove the default virtio interface

Add a virtual network interface in which the source is br0-net

Add host device (to passthrough the USB NIC)
-> `lsusb` to double check the name for the USB NIC


Then install

Download the pfSense CE from `https://www.pfsense.org/download/`


## Install tailscale inside pfSense
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
