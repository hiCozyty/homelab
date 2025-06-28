
## Requirements
- 1 dedicated PC to run RHEL host (with ethernet port and wireless card recommended)
- 1 USB to Ethernet NIC (2.5Gbps or higher)
- Wireless router with AP mode support
  
## Setup requirements
1. USB NIC = **WAN input** from ISP 
  -> this goes **to pfSense VM**
  
2. Motherboard NIC = **LAN output** physically connects to home router
   -> this also goes **to pfSense VM** 

3. pfSense runs inside a VM, **acts as the firewall/router**

4. RHEL host **should not** access the internet directly via USB NIC


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

for me: `enp5s0f3u1`
Check thruput with `lsusb -t`
Choose usb port with 2500M or higher

## Remove default virtual network
```
sudo virsh net-destroy default
sudo virsh net-autostart --disable default
sudo virsh net-undefine default
```

## Setup pfSense VM via cockpit

Go to `localhost:9090`

Enable admin access

Click Virtual Machines then Create and edit

Remove the default virtio network interface

Here you have two options

-> Add a **direct attachment**  network type for both the USB-NIC and mobo NIC 

OR

-> Add a **direct attachment** for mobo NIC (because IOMMU groups are not cleanly separated and requires a kernel patch) and direct USB passthru to the vm

see **Performance considerations** sections to decide which option to choose

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
Ensure WAN traffic only go thru pfSense and not get routed to the host when pfSense VM crashes or turns off.

IMPORTANT: change `enp5s0f3u1` to the correct USB-Ethernet nic name

```
sudo tee /etc/NetworkManager/conf.d/10-unmanaged-enp5s0f3u1.conf > /dev/null <<EOF
[keyfile]
unmanaged-devices=interface-name:enp5s0f3u1
EOF

sudo systemctl restart NetworkManager
```

Establish Wifi connection from RHEL host to AP mode router (recommended)
-> only connect if RHEL host needs access to the internet for occasional updates
-> otherwise, keep it disconnected from internet

then turn VM off, to make sure that host does not have access to internet. 

Then turn VM on , to make sure that host does have access to internet.

Enable auto start for pfSense VM

Alternatively, for better segmentation, passthru BOTH the USB-nic as well as mobo-nic into the pfSense vm. Host will not have internet unless connected via wifi router (ap mode)

Restart to apply changes
```
sudo systemctl restart NetworkManager
```

## Performance considerations

Reference device: **x300 deskmini with 5600g ryzen cpu**

Home internet speed: **500mbps**

### Host 

**cpu**: 1.2v 2.6ghz 35w profile 

**memory**: 1.2v 2600


### pfSense vm 

**cores allocated**: 2 - 8

**memory**: 8gb

| Method     | 2 Cores     | 4 Cores      | 8 Cores      |
|:-----------|:-----------:|:------------:|-------------:|
| macvtap    | 450–500 Mbps| 450-500 Mbps | 450-500 Mbps |
| passthru   | 27-30 Mbps  | 30-32 Mbps   | 35-37 Mbps   |


## Power consumption benchmarks
...
