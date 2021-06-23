#!/bin/bash

start_ssredir() {
	(sslocal -c /etc/ss/config.json </dev/null &>>/var/log/ss-redir.log &)
}

stop_ssredir() {
	kill -9 $(pidof sslocal) &>/dev/null
}

start_ipset() {
	ipset restore -f /etc/ipset/reserved.ipset
	ipset restore -f /etc/ipset/china.ipset
	ipset restore -f /etc/ipset/vps.ipset
}

stop_ipset() {
	ipset destroy reserved.ipset &>/dev/null
	ipset destroy china.ipset &>/dev/null
	ipset destroy vps.ipset &>/dev/null
}

start_iptables() {
	##################### PREROUTING #####################
	iptables -t mangle -N SS
	# Ignore
	iptables -t mangle -A SS -p tcp -m set --match-set reserved.ipset dst -j RETURN
	iptables -t mangle -A SS -p udp -m set --match-set reserved.ipset dst -j RETURN

	iptables -t mangle -A SS -p tcp -m set --match-set china.ipset dst -j RETURN
	iptables -t mangle -A SS -p udp -m set --match-set china.ipset dst -j RETURN

	iptables -t mangle -A SS -p tcp -m set --match-set vps.ipset dst -j RETURN
	iptables -t mangle -A SS -p udp -m set --match-set vps.ipset dst -j RETURN

	iptables -t mangle -A SS -p udp -j TPROXY --on-ip 127.0.0.1 --on-port 1080 --tproxy-mark 0x2333
	iptables -t mangle -A SS -p tcp -j TPROXY --on-ip 127.0.0.1 --on-port 1080 --tproxy-mark 0x2333
	# Apply
	iptables -t mangle -A PREROUTING -j SS


	##################### OUTPUT #####################
	iptables -t mangle -N SS-MARK
	# Ignore
	iptables -t mangle -A SS-MARK -p tcp -m set --match-set reserved.ipset dst -j RETURN
	iptables -t mangle -A SS-MARK -p udp -m set --match-set reserved.ipset dst -j RETURN

	iptables -t mangle -A SS-MARK -p tcp -m set --match-set china.ipset dst -j RETURN
	iptables -t mangle -A SS-MARK -p udp -m set --match-set china.ipset dst -j RETURN

	iptables -t mangle -A SS-MARK -p tcp -m set --match-set vps.ipset dst -j RETURN
	iptables -t mangle -A SS-MARK -p udp -m set --match-set vps.ipset dst -j RETURN
	# Reroute
	iptables -t mangle -A SS-MARK -p udp -j MARK --set-mark 0x2333
	iptables -t mangle -A SS-MARK -p tcp -j MARK --set-mark 0x2333
	# Apply
	iptables -t mangle -A OUTPUT -j SS-MARK

}

stop_iptables() {
	##################### PREROUTING #####################
	iptables -t mangle -D PREROUTING -j SS &>/dev/null

	##################### OUTPUT #####################
	iptables -t mangle -D OUTPUT -j SS-MARK &>/dev/null

	##################### SSREDIR #####################
	iptables -t mangle -F SS &>/dev/null &>/dev/null
	iptables -t mangle -X SS &>/dev/null &>/dev/null

	iptables -t mangle -F SS-MARK &>/dev/null
	iptables -t mangle -X SS-MARK &>/dev/null
}

start_iproute2() {
	# Strategy Route
	ip -4 route add local 0/0 dev lo 	table 100
	ip -4 rule add fwmark 0x2333 		table 100
}

stop_iproute2() {
	ip -4 rule  del   table 100 &>/dev/null
	ip -4 route flush table 100 &>/dev/null
}

start_resolvconf() {
	echo "nameserver 127.0.0.1" >/etc/resolv.conf
	echo "server=127.0.0.1#55353" >/etc/dnsmasq.d/upstream-nameserver.conf
}

stop_resolvconf() {
	echo "server=114.114.114.114" >/etc/dnsmasq.d/upstream-nameserver.conf
}

start() {
	echo "start ..."
	start_ssredir
	start_ipset
	start_iptables
	start_iproute2
	start_resolvconf
	echo "start end"
}

stop() {
	echo "stop ..."
	stop_resolvconf
	stop_iproute2
	stop_iptables
	stop_ipset
	stop_ssredir
	echo "stop end"
}

restart() {
	stop
	sleep 1
	start
}

main() {
	if [ $# -eq 0 ]; then
		echo "usage: $0 start|stop|restart ..."
		return 1
	fi

	for funcname in "$@"; do
		if [ "$(type -t $funcname)" != 'function' ]; then
			echo "'$funcname' not a shell function"
			return 1
		fi
	done

	for funcname in "$@"; do
		$funcname
	done
	return 0
}
main "$@"

