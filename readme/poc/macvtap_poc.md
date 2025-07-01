# Title place holder

For the purpose of comparing different macvtap modes, we will comment out the unmanaged line in this config: ` /etc/NetworkManager/conf.d/10-unmanaged-enp5s0f3u1.conf`

## macvtap mode for WAN interface comparison table

|    | vepa | bridge | private | passthru |
|:--|:-----|:-------|:--------|:-------- |
| Internet Connection | ✅ | ✅ | ✅ | ❌ |
