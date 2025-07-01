# Evaluating `macvtap` Modes for Network Isolation and Host Security
![image](https://access.redhat.com/webassets/avalon/d/Red_Hat_Enterprise_Linux-6-Virtualization_Administration_Guide-en-US/images/cd8ec3282ce056149aee12728b14312b/macvtap_modes-Private.png)
[*source: 18.11. Attaching a Virtual NIC Directly to a Physical Interface*](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/virtualization_administration_guide/sect-attch-nic-physdev)
1. For the purpose of comparing different macvtap modes, we will comment out the unmanaged line in this config: `/etc/NetworkManager/conf.d/10-unmanaged-enp5s0f3u1.conf`.

2. Then `sudo systemctl restart NetworkManager`.

## macvtap mode for WAN interface comparison table

|    | vepa | bridge | private | passthru |
|:--|:-----|:-------|:--------|:-------- |
| Internet Connection | ✅ | ✅ | ✅ | ❌ |
