# Homelab 

## Requirements
- 1 dedicated PC to run RHEL host
- 1 USB to Ethernet NIC (2.5Gbps or higher)
- Wireless router with AP mode support
  
## Setup requirements
1. USB NIC = **WAN input** from ISP 
  -> this goes **to pfSense VM**
  
2. Motherboard NIC = **LAN output** physically connects to home router
   -> this also goes **to pfSense VM** 

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

Physically connect the router/AP (LAN port) to the motherboard NIC

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

## Setup VM network

Remove default virtual network
```
sudo virsh net-destroy default
sudo virsh net-autostart --disable default
sudo virsh net-undefine default
```
Restart to apply changes
```
sudo systemctl restart NetworkManager
```

## Setup pfSense VM via cockpit

Go to localhost:9090

Enable admin access

Click Virtual Machines then Create and edit

Remove the default virtio network interface

Add a **direct attachment**  network type for both the USB-NIC and mobo NIC 

This should create 2 macvtap network interfaces

No passthrough is required

Download the pfSense CE from `https://www.pfsense.org/download/`

Extract the `gz` file 
```
gunzip netgate-installer-amd64.iso.gz 
```
Move to correct directory to fix permissions issue
```
sudo mv /home/$USER/Downloads/netgate-installer-amd64.iso /var/lib/libvirt/images/
sudo chown qemu:qemu /var/lib/libvirt/images/netgate-installer-amd64.iso

```

During pfSense installation, make sure to use the USB NIC for the WAN mobo NIC for LAN

Make sure to enable AP mode on router and set DHCP to auto so that pfSense can handle DHCP 

Go to `http://192.168.1.1` for the pfSense dashboard
Default login is `admin:pfsense`
Change password


## Disable DHCP autoconnect for the usb-eth nic
ensure WAN traffic only go thru pfSense and not get routed to the host when pfSense VM crashes or turns off.

IMPORTANT: change `enp5s0f4u2u2` to the correct USB-Ethernet nic name

```
sudo tee /etc/NetworkManager/conf.d/10-unmanaged-enp5s0f4u2u2.conf > /dev/null <<EOF
[keyfile]
unmanaged-devices=interface-name:enp5s0f4u2u2
EOF

sudo systemctl restart NetworkManager
```
