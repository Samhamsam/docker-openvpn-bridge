#!/bin/bash
# Needed for openvpn
mkdir -p /run/openvpn
mkdir -p /dev/net
mknod /dev/net/tun c 10 200

ip link del dev tap0 ;

echo "create dev tap0 with openvpn --mktun"
openvpn --mktun --dev tap0 ;

echo "tap0 promisc on up"
ip link set tap0 promisc on up ;

echo "eno1 promisc on up"
ip link set eno1 promisc on up ;

echo "add tap0 to br0"
brctl addif br0 tap0 ;


chown -R nobody:nogroup /etc/openvpn
chmod -R 700 /etc/openvpn

echo "enable forwarding"

#Please activate forwarding on the host.

# Run actual OpenVPN
exec /usr/sbin/openvpn --writepid /run/openvpn/server.pid --cd /etc/openvpn --config /etc/openvpn/server.conf --script-security 2
