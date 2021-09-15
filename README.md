# ss-openwrt-transparent-proxy-router
openwrt transparent proxy router configuration using ss

## deploy (openwrt >= 21.02, 64bit)

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

### Git clone this project also [the ss-port-mapping project](https://github.com/kokrange/ss-port-mapping) to your openwrt and change custom values(words start with your_***) in following files:
* docker-compose.yaml(files from [here](https://github.com/kokrange/ss-port-mapping))
* config.json
* vps.ipset


### Local, remote machine service deploy(files from [here](https://github.com/kokrange/ss-port-mapping))
* each server with server/docker-compose.yaml (this is for your vps nodes, you should git clone [the ss-port-mapping project](https://github.com/kokrange/ss-port-mapping) to each of your servers, and change the custom values.)
* client with many client/docker-compose.yaml (this is for your openwrt. e.g. if you have 2 vps nodes, then you should have 2 folders: node1/docker-compose.yaml, node2/docker-comopse.yaml on your openwrt.)
```bash
docker-compose up -d
```


### Openwrt files copy:
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
mv sslocal /user/bin/
sslocal --help
```
* if you can see the help output from `sslocal --help`, then your sslocal is installed correctly.


### Openwrt gui:
* lan interface uncheck: bridge.
* wan interface uncheck: Use DNS servers advertised by peer.
* disable IPv6 for lan and wan, especially for wan.
* dns ignore resolv, hosts files.


### Terminal command:
```bash
service dnsmasq restart
service vpn start
service vpn enable
```


### Log:
```bash
tail -n 100 /var/log/ss-redir.log
```
