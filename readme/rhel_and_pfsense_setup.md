# Hardware Requirements

1. x86-64 PC to install and run [RHEL (Red Hat Enterprise Linux)](https://developers.redhat.com/products/rhel/download) host.
2. Ethernet port.
3. USB to Ethernet NIC (Network Interface Controller).
4. Wireless card.
5. Wireless router with AP (Access Point) capability.

    ->If Wi-Fi Mesh is needed, consider getting an AP that supports mesh like Unifi or TP-Link Omada.

# Setup Requirements

1. USB-NIC is the **WAN input** from ISP.

    -> this is passed thru to the **pfSense VM (Virtual Machine)**.

2. Motherboard NIC is the **LAN input**.

    -> this is passed thru to the **pfSense VM**.

3. pfSense runs inside a VM and **acts as the firewall/router** for the RHEL host.

4. AP Router is connected to the LAN port.

5. RHEL host **should not** access the internet via USB-NIC. Instead it connects to AP as a wireless client.


# Guided Script
-Todo-

# Manual Setup

## Setting up Virtualization in RHEL

1. Update system and install the necessary packages.

```bash
sudo dnf update
sudo dnf install qemu-kvm libvirt virt-install cockpit cockpit-machines

#no need to run as cockpit.socket is a root service
#sudo usermod -aG libvirt,kvm $USER
```

2. Physically connect the AP (using its LAN port) to the motherboard NIC.

3. Reboot.

## Setup Cockpit

1. Adjust firewall settings and start the service.

```bash
sudo firewall-cmd --add-port=9090/tcp
sudo firewall-cmd --permanent --add-port=9090/tcp
sudo systemctl enable cockpit.socket
sudo systemctl start cockpit.socket
```

2. Remove default virtual network.

```bash
sudo virsh net-destroy default
sudo virsh net-autostart --disable default
sudo virsh net-undefine default
```

3. Get the name of the USB-NIC.

```bash
ip -br a | grep '\/' | awk '{print $1|'
```
  -> For example, mine is `enp5s0f3u1`.

  -> Check thruput with `lsbusb -t`.

  -> Make sure USB port with speeds matching the USB-NIC specs or higher.

## Install `dnf-automatic` and `kernel live patching`

1.Install the required packages.

```bash
sudo dnf install kpatch
sudo dnf install kpatch-dnf
sudo dnf kpatch auto
```

2. Setup automatic updates.

```bash
sudo dnf install dnf-automatic
sudo systemctl enable --now dnf-automatic.timer

sudo tee /etc/dnf/automatic.conf > /dev/null << EOF
[commands]
apply_updates = yes

[emitters]
# send email notifications to root (optional)
emit_via = stdio

[base]
# debuglevel = 1
EOF
```

3. Customize update schedule
```bash
sudo systemctl edit --full dnf-automatic.timer
```

4. Go to the cockpit dashboard's **Software Updates** tab `https://localhost:9090/updates`

5. Enable `Kernel live patching`


## Setup pfSense VM via cockpit

1. Go to `localhost:9090`.

2. Enable admin access.

3. Click on Virtual Machines. Then Create and edit.

4. Remove the default `virtio` network Interface.

5. Here, you have two options.

    a) Add a **direct attachement** network type for both the USB-NIC and motherboard NIC.

    b) Add a **direct attachment** network type for the motherboard NIC but direct USB passthru for the USB-NIC.

      *Note: Due to how most PCs **do not** have IOMMU groups that are not cleanly separated for the motherboard NIC, it requires a **kernel patch** for direct hardware passthru.*

      *See [**Performance considerations**](./readme/rhel_and_pfsense_setup.md#performance-considerations) section to decide which option to choose.*

6. Download the [pfSense CE (Community Edition)](https://www.pfsense.org/download/).

7. Extract the `gz` file.

```bash
gunzip netgate-installer-amd64.iso.gz
```

8. Fix permissions (if needed).

```bash
sudo chown qemu:qemu netgate-installer-amd64.iso
```

9. During pfSense installation, make sure to use the USB-NIC for the WAN and the motherboard NIC for the LAN.

10. At this point, make sure that the router has AP mode on.

11. Go to the pfSense dashboard at `http://192.168.1.1`. Default login is `admin:pfsense`. Then change the password.

## Disable DHCP autoconnect for the USB-NIC

1. Ensure WAN traffic only goes thru pfSense and not get routed to the host when pfSense VM crashes or turns off.

    *Note: change `enp5s0f3u1` to the correct USB-NIC name.*


```bash
sudo tee /etc/NetworkManager/conf.d/10-unmanaged-enp5s0f3u1.conf > /dev/null <<EOF
[keyfile]
unmanaged-devices=interface-name:enp5s0f3u1
EOF

sudo systemctl restart NetworkManager
```

2. Establish Wifi connection from RHEL host to AP mode router.

    a) Turn VM off, to make sure that host does not have access to internet.

    b) Turn VM on , to make sure that host does have access to internet.

3. Enable auto start for pfSense VM.

4. Reboot.

## Set macvtap mode to `Private`

1. Edit the VM XML file.

```bash
sudo virsh edit pfSense # replace pfSense with your VM name
```

2. Find the `<Interface>` section and set mode to `mode='private'`.

```
<interface type='direct'>
  <mac address='12:34:56:78:90:12'/>
  <source dev='enp3s0' mode='bridge'/>
  <model type='virtio'/>
  <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
</interface>

<interface type='direct'>
  <mac address='12:34:56:78:90:13'/>
  <source dev='enp5s0f3u1' mode='bridge'/>
  <model type='virtio'/>
  <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>
</interface>
```

  *Note: this provides the following:*

  **1. Guest to Guest isolation over the same NIC.**

  **2. RHEL host cannot communicate with the VMs via that interface.**

  **3. All traffic must go through your firewall/router (pfSense).**

  **4. VMs can talk to the outside world (e.g. internet) via pfSense.**


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
-Todo



# References

https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/virtualization_host_configuration_and_guest_installation_guide/app_macvtap

https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/virtualization_administration_guide/sect-attch-nic-physdev
