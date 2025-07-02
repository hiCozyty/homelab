# VLAN Setup

## Setup VLANs from the pfSense GUI

1. Goto `https://192.168.1.1/interfaces_vlan.php`

2. Create Vlans based on the [segmentation table](https://github.com/hiCozyty/homelab/tree/main?tab=readme-ov-file#lanvlan-segmentation-table)

3. Use `LAN` for the parent interface

## Create VLAN subinterfaces on RHEL host

1. Create dummy interface the host doesnt even use.
```bash
sudo nmcli connection add type vlan con-name vlan10 dev enp3s0 id 10
sudo nmcli connection add type vlan con-name vlan20 dev enp3s0 id 20
sudo nmcli connection add type vlan con-name vlan30 dev enp3s0 id 30
sudo nmcli connection add type vlan con-name vlan40 dev enp3s0 id 40
sudo nmcli connection add type vlan con-name vlan50 dev enp3s0 id 50
sudo nmcli connection add type vlan con-name vlan60 dev enp3s0 id 60
```
