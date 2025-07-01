## Setup VLANs from the pfSense GUI
1. Goto `https://192.168.1.1/interfaces_vlan.php`
2. Create Vlans based on the [segmentation table](https://github.com/hiCozyty/homelab/tree/main?tab=readme-ov-file#lanvlan-segmentation-table)
3. Use `LAN` for the parent interface

## Configure a single purpose jumpbox VM on VLAN40
1. Download [openBSD iso](https://www.openbsd.org/faq/faq4.html#Download)
2. Create a new VM using 1vCPU, 1gb ram, and 1gb storage
   
References:
[Securing Jumpboxes]
(https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/implementing-secure-administrative-hosts)
