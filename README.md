# Homelab

## Architecture Overview

![infra](https://github.com/user-attachments/assets/22de9893-fad7-4e64-984d-abbb8bae24a9)


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

1. [Centralized Credentials Management](./readme/centralized_credentials_management.md)

2. [RHEL Host and pfSense VM Setup](./readme/rhel_and_pfsense_setup.md)

  -   [Evaluating macvtap Modes for Network Isolation and Host Security](./readme/macvtap_host_eval.md)

3. [VLAN setup](https://github.com/hiCozyty/homelab/blob/main/readme/vlan_setup.md)

4. [Jumpbox setup](./readme/jumpbox_setup.md)
