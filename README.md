# ss-openwrt-transparent-proxy-router
openwrt transparent proxy router configuration using ss

## deploy (openwrt >= 21.02, 64bit)

openwrt software(opkg install):
* bash
* docker
* dockerd
* docker-compose
* iptables-mod-tproxy
* ipset

change custom value(words start with your_***) in following files:
* docker-compose.yaml
* config.json
* vps.ipset

local, remote machine deploy(files from [here](https://github.com/kokrange/ss-port-mapping))
* servers with server/docker-compose.yaml
* client with many client/docker-compose.yaml

openwrt file copy:
* config.json -> /etc/ss/config.json
* dnsmasq.conf -> /etc/dnsmasq.conf
* dnsmasq.d/ -> /etc/dnsmasq.d/
* ipset/ -> /etc/ipset/
* ss -> /usr/bin/ss
* vpn -> /etc/init.d/vpn
* sslocal(extracted from [here](https://github.com/shadowsocks/shadowsocks-rust/releases)) -> /usr/bin/sslocal

openwrt gui:
* lan interface uncheck: bridge.
* wan interface uncheck: Use DNS servers advertised by peer.
* dns ignore resolv, hosts files.

terminal command:
* service dnsmasq restart
* service vpn start(or restart)
* service vpn enable
