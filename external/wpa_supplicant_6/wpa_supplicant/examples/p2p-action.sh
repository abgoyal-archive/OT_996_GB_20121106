#!/bin/sh

IFNAME=$1
CMD=$2


kill_daemon() {
	NAME=$1

	sup_pid=`ps | grep $NAME  | awk '{ print $2 }'`
	if [ -n "${sup_pid}" ]; then
   		echo kill -9 $sup_pid
   		kill -9 $sup_pid
	fi
}


if [ "$CMD" = "P2P-GROUP-STARTED" ]; then
    GIFNAME=$3
    if [ "$4" = "GO" ]; then
	if [ -f /data/misc/dhcp/dhcpcd-$GIFNAME.lease ]; then
		echo removing file /data/misc/dhcp/dhcpcd-$GIFNAME.lease
		rm /data/misc/dhcp/dhcpcd-$GIFNAME.lease
	fi

	kill_daemon dnsmasq
	ifconfig $GIFNAME 192.168.42.1 up
	echo starting dnsmasq

	if ! dnsmasq --pid-file  \
	    -i $GIFNAME \
	    -F192.168.42.11,192.168.42.99; then
	    # another dnsmasq instance may be running and blocking us; try to
	    # start with -z to avoid that
	    echo trying to start with -z
	    dnsmasq --pid-file  \
		-i $GIFNAME -k\
		-F192.168.42.11,192.168.42.99 --listen-address 192.168.42.1 -z
	    echo started with -z
	fi
    fi
    if [ "$4" = "client" ]; then
	kill_daemon dhcpcd /data/misc/dhcp/dhcpcd-$GIFNAME.pid
	rm /data/misc/dhcp/dhcpcd-$GIFNAME.lease
	kill_daemon dnsmasq /data/misc/dhcp/dnsmasq.pid-$GIFNAME
	dhcpcd $GIFNAME -p /data/misc/dhcp/dhcpcd-$GIFNAME.pid \
	    -lf /data/misc/dhcp/dhcpcd-$GIFNAME.lease
    fi
fi

if [ "$CMD" = "P2P-GROUP-REMOVED" ]; then
    GIFNAME=$3
    if [ "$4" = "GO" ]; then
	kill_daemon dnsmasq /data/misc/dhcp/dnsmasq.pid-$GIFNAME
	ifconfig $GIFNAME 0.0.0.0
    fi
    if [ "$4" = "client" ]; then
	kill_daemon dhcpcd /data/misc/dhcp/dhcpcd-$GIFNAME.pid
	rm /data/misc/dhcp/dhcpcd-$GIFNAME.lease
	ifconfig $GIFNAME 0.0.0.0
    fi
fi

if [ "$CMD" = "P2P-CROSS-CONNECT-ENABLE" ]; then
    GIFNAME=$3
    UPLINK=$4
    # enable NAT/masquarade $GIFNAME -> $UPLINK
    iptables -P FORWARD DROP
    iptables -t nat -A POSTROUTING -o $UPLINK -j MASQUERADE
    iptables -A FORWARD -i $UPLINK -o $GIFNAME -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i $GIFNAME -o $UPLINK -j ACCEPT
    sysctl net.ipv4.ip_forward=1
fi

if [ "$CMD" = "P2P-CROSS-CONNECT-DISABLE" ]; then
    GIFNAME=$3
    UPLINK=$4
    # disable NAT/masquarade $GIFNAME -> $UPLINK
    sysctl net.ipv4.ip_forward=0
    iptables -t nat -D POSTROUTING -o $UPLINK -j MASQUERADE
    iptables -D FORWARD -i $UPLINK -o $GIFNAME -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -D FORWARD -i $GIFNAME -o $UPLINK -j ACCEPT
fi
echo calling exit
exit 1
