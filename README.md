# ss-openwrt-transparent-proxy-router
High Availability & Full network protocols TCP/UDP supported. 
openwrt transparent proxy router configuration using ss.

![plot](./arch.png)

## How to deploy (require openwrt >= 21.02, on arm/x86[32bit/64bit]. Tested: 21.02.3)

### Install openwrt software(opkg install):
* bash
* docker
* dockerd
* docker-compose
* iptables-mod-tproxy
* ipset
* git
* git-http
* dnscrypt-proxy2
```bash
opkg update
opkg install git git-http dnscrypt-proxy2 bash dockerd docker docker-compose iptables-mod-tproxy ipset htop lsblk lscpu vim-full tar curl
```
* If your openwrt use usb-to-ether adapter, you should also install:
* kmod-usb-net-cdc-ether kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 (for most usb2.0 adapters)
* kmod-usb-net-asix-ax88179 (for latest usb3.0 adapters)
```bash
opkg install kmod-usb-net-cdc-ether kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 kmod-usb-net-asix-ax88179
```


### Openwrt / VPS node service deployment (docker-compose files in /compose folder, also see [the ss-port-mapping project](https://github.com/kokrange/ss-port-mapping))
* Each VPS node should have one vps/docker-compose.yaml (you should vps/docker-compose.yaml to each of your servers, then change the custom values.)
* Openwrt should have many openwrt/docker-compose.yaml (e.g. if you have 2 vps nodes, then you should have 2 folders: node1/docker-compose.yaml, node2/docker-comopse.yaml on your openwrt.)
* Change custom values in all docker-comopse.yaml(words start with your_*** )
* kcp_port_range format: min-max (e.g. 10000-10200), it require approximately 512M memory per 100 ports for kcptun server(kcps) on VPS node.
* start docker
```bash
docker-compose up -d
```
* Some Cloud Services have port restrictions, if that's the case, you should add all exposed UDP ports(in vps/docker-comopse.yaml) to whitelist.


### Openwrt gui:
* Lan interface uncheck: bridge. (WARN: br-lan will not work!)
* Wan interface uncheck: Use DNS servers advertised by peer. (Or Not. for some version of openwrt)
* Disable IPv6 for lan and wan, especially for wan. (WARN: IPv6 proxy are not supported.)
* DNS ignore resolv, hosts files.


### Openwrt proxy config: change custom values(words start with your_***) in following files:
* config.json
* ipset/vps.ipset

### Openwrt proxy config install:
* config.json -> /etc/ss/config.json
* dnsmasq.conf -> /etc/dnsmasq.conf
* dnsmasq.d/ -> /etc/dnsmasq.d/
* ipset/ -> /etc/ipset/
* ss -> /usr/bin/ss
* vpn -> /etc/init.d/vpn
* dnscrypt-proxy.toml -> /etc/dnscrypt-proxy2/dnscrypt-proxy.toml
```bash
mkdir /etc/ss && \
mv config.json /etc/ss/ && \
mv dnsmasq.conf /etc/ && \
mv dnsmasq.d/ /etc/ && \
mv ipset/ /etc/ && \
mv ss /usr/bin/ && \
mv vpn /etc/init.d/ && \
mv dnscrypt-proxy.toml /etc/dnscrypt-proxy2/dnscrypt-proxy.toml
```

### Install sslocal
* sslocal(extracted from [here](https://github.com/shadowsocks/shadowsocks-rust/releases)) -> /usr/bin/sslocal
* for arm64: shadowsocks-y.y.y.aarch64-unknown-linux-musl.tar.xz
* for x86_amd64: shadowsocks-y.y.y.x86_64-unknown-linux-musl.tar.xz
* for arm7: shadowsocks-y.y.y.armv7-unknown-linux-musleabihf.tar.xz
* for x86: shadowsocks-y.y.y.i686-unknown-linux-musl.tar.xz

```bash
chmod 755 sslocal
mv sslocal /usr/bin/
sslocal --help
```
* if you can see the help output from `sslocal --help`, then your sslocal is installed correctly.


### Command(after all things configured correctly):
```bash
service vpn start
service vpn enable
service dnsmasq restart
service dnscrypt-proxy restart
service dnscrypt-proxy enable
```


### Log:
```bash
tail -n 100 /var/log/ss-redir.log
```
