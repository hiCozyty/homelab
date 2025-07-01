# mode='passthrough' is the way
![image](https://access.redhat.com/webassets/avalon/d/Red_Hat_Enterprise_Linux-6-Virtualization_Administration_Guide-en-US/images/cd8ec3282ce056149aee12728b14312b/macvtap_modes-Private.png)
[*source*](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/virtualization_administration_guide/sect-attch-nic-physdev)

For the purpose of comparing different macvtap modes, we will comment out the unmanaged line in this config: `/etc/NetworkManager/conf.d/10-unmanaged-enp5s0f3u1.conf`

## macvtap mode for WAN interface comparison table

|    | vepa | bridge | private | passthru |
|:--|:-----|:-------|:--------|:-------- |
| Internet Connection | ✅ | ✅ | ✅ | ❌ |
