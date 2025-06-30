# Homelab 

## Architecture Overview
![architecture drawio(2)](https://github.com/user-attachments/assets/ce9aab98-75e9-4dd0-90f4-45e7ef0969b1)


## LAN/VLAN segmentation table
| Name     | ID  | Subnet       | Purpose    | Example VMs |
|:---------|:---:|:------------:|-----------:|------------:|
| LAN      | 10  | 192.168.1.0/24  | Home Wi-Fi, AP/Router | N/A |
| Attacker | 20  | 192.168.20.0/24  | Offensive VMs | Kali, parrot |
| Vuln     | 30  | 192.168.30.0/24  | Vuln VMs | Windows, Linux, DVWA, metasploitable |
| Mgmt     | 40  | 192.168.40.0/24  | Admin access, UI Panels | Admin PC, pfSense Gui, Omada Controller, Logging VM |
| Blog     | 100 | 192.168.100.0/24  | Self-hosted web service | Ghost Blog VM |
| Backup    | 200 | 192.168.200.0/24  |	Backup servers for all VM snapshots/backups | Backup VMs |


## Installation
[Base setup](https://github.com/hiCozyty/homelab/blob/main/readme/base_homelab_setup.md)


[Basic hardening](https://github.com/hiCozyty/homelab/blob/main/readme/basic_hardening.md)

[VLAN setup](https://github.com/hiCozyty/homelab/blob/main/readme/vlan_setup.md)
