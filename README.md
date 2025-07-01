# Homelab

## Architecture Overview
![image](https://github.com/user-attachments/assets/05f2538a-a220-495a-b0a7-f8c8ab60e6c4)



## LAN/VLAN segmentation table
| Name     | ID    | Subnet       | Purpose    | Example VMs |
|:---------|:-----:|:------------:|-----------:|------------:|
| LAN      |    | 192.168.1.0/24  | Home Wi-Fi, AP/Router |  |
| Attacker | 10    | 192.168.10.0/24  | Offensive VMs | Kali, parrot |
| Vuln     | 20    | 192.168.20.0/24  | Vuln VMs | Windows, Linux, DVWA, metasploitable |
| Mgmt     | 30    | 192.168.30.0/24  | Admin access, UI Panels | Admin PC, pfSense Gui, Omada Controller, Logging VM |
| Jumpbox  | 40    | 192.168.40.0/24  | | jumpbox VM|
| Blog     | 100   | 192.168.100.0/24  | Self-hosted web service | Ghost Blog VM |
| Backup   | 200   | 192.168.200.0/24  |	Backup servers for all VM snapshots/backups | Backup VMs |


## Installation
[RHEL host and pfSense VM setup](./readme/rhel_and_pfsense_setup.md)

  -   [macvtap Interface Mode Security PoC](./readme/poc/macvtap_poc.md)

[VLAN setup](https://github.com/hiCozyty/homelab/blob/main/readme/vlan_setup.md)

[Basic hardening](https://github.com/hiCozyty/homelab/blob/main/readme/basic_hardening.md)
