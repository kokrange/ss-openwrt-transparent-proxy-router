# ss-openwrt-transparent-proxy-router
High Availability & Full network protocols TCP/UDP supported. 
openwrt transparent proxy router configuration using ss.

![plot](./arch.png)

## How to deploy (require openwrt >= 21.02, 64bit)

### Install openwrt software(opkg install):
* bash
* docker
* dockerd
* docker-compose
* iptables-mod-tproxy
* ipset
* git
* git-http
```bash
opkg update
opkg install git git-http bash dockerd docker docker-compose iptables-mod-tproxy ipset
```
* If your openwrt use usb-to-ether adapter, you should also install:
* kmod-usb-net-cdc-ether (for most usb2.0 adapters)
* kmod-usb-net-asix-ax88179 (for latest usb3.0 adapters)
```bash
opkg install kmod-usb-net-cdc-ether kmod-usb-net-asix-ax88179
```


### Openwrt / VPS node service deployment (files from [the ss-port-mapping project](https://github.com/kokrange/ss-port-mapping))
* Each VPS node should have one server/docker-compose.yaml (you should git clone [the ss-port-mapping project](https://github.com/kokrange/ss-port-mapping) to each of your servers, and change the custom values.)
* Openwrt should have many client/docker-compose.yaml (e.g. if you have 2 vps nodes, then you should have 2 folders: node1/docker-compose.yaml, node2/docker-comopse.yaml on your openwrt.)
* Change custom values in docker-comopse.yaml(words start with your_*** ), then
```bash
docker-compose up -d
```
* Some Cloud Services have port restrictions, if that's the case, you should add all exposed UDP ports(in server/docker-comopse.yaml) to whitelist.

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
```bash
mkdir /etc/ss && \
mv config.json /etc/ss/ && \
mv dnsmasq.conf /etc/ && \
mv dnsmasq.d/ /etc/ && \
mv ipset/ /etc/ && \
mv ss /usr/bin/ && \
mv vpn /etc/init.d/
```

### Install sslocal
* sslocal(extracted from [here](https://github.com/shadowsocks/shadowsocks-rust/releases)) -> /usr/bin/sslocal
* for arm64: shadowsocks-y.y.y.aarch64-unknown-linux-musl.tar.xz
* for x86_amd64: shadowsocks-y.y.y.x86_64-unknown-linux-musl.tar.xz
```bash
chmod 755 sslocal
mv sslocal /usr/bin/
sslocal --help
```
* if you can see the help output from `sslocal --help`, then your sslocal is installed correctly.


### Openwrt gui:
* Lan interface uncheck: bridge. (WARN: br-lan will not work!)
* Wan interface uncheck: Use DNS servers advertised by peer.
* Disable IPv6 for lan and wan, especially for wan. (WARN: IPv6 proxy are not supported.)
* DNS ignore resolv, hosts files.


### Command(after all things configured correctly):
```bash
service dnsmasq restart
service vpn start
service vpn enable
```


### Log:
```bash
tail -n 100 /var/log/ss-redir.log
```
