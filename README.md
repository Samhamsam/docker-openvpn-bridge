# Required "DATA" directory for OpenVPN

This container assumes you have a "/data" (or like) directory with your server config and certs like so:

```
/data/certs:
  ca.crt
  dh.pem (optional, you can also use an elliptic curve)
  server.crt
  server.key
  ta.key (technically "optional" - in reality a must for security)
  crl.pem (optional - revoke list)

/data:
  server.conf
```


## Server Config (eliptic curve)
```
port 1194
proto udp
dev tap0
ca certs/ca.crt
cert certs/server.crt
key certs/server.key  # This file should be kept secret
dh none
ecdh-curve secp521r1 #only if you use eliptic curve
server-bridge 192.168.1.100 255.255.255.0 192.168.1.200 192.168.1.220
keepalive 10 120
tls-version-min 1.2
tls-auth certs/ta.key 0 # This file is secret
cipher AES-256-GCM
max-clients 5
persist-key
persist-tun
user nobody
group nogroup
status openvpn-status.log
log         openvpn.log
log-append  openvpn.log
verb 4
mssfix 1305
```


## Client Config
```
client
dev tap0
remote vpn-server-host.tld 1194 udp
persist-key
persist-tun
verb 4
tls-client
tls-version-min 1.2
cipher AES-256-GCM
key-direction 1
<ca>
# Insert "ca.crt"
</ca>
<cert>
# Insert "client.crt"
</cert>
<key>
# Insert "client.key"
</key>
<tls-auth>
# Insert "ta.key"
</tls-auth>
```

## Iptables
```
iptables -t nat -I POSTROUTING -o <eth> -j MASQUERADE
```

## Network configuration
### Ubuntu 20.04
/etc/netplan/00-installer-config.yaml
```
network:
  ethernets:
    <eth>:
      dhcp4: no
  bridges:
    br0:
       dhcp4: no
       interfaces: [<eth>]
       addresses: [192.168.1.120/24]
       gateway4: 192.168.1.1
       nameservers:
         addresses: [1.1.1.1, 1.0.0.1]
  version: 2
```
Please change <eth> to your ethernet interface.

### Add these rules to the linux server
```
    iptables -A INPUT -i tap0 -j ACCEPT
    iptables -A INPUT -i br0 -j ACCEPT
    iptables -A FORWARD -i br0 -j ACCEPT
```
  
  
# How to run the OpenVPN Docker Container?
```
docker run -it -d --restart=always --name=openvpn  -p 1194:1194/udp --cap-add=NET_ADMIN -v /home/<name>/data/:/etc/openvpn --network=host samhamsam/openvpn-bridge
```

# Sugestions?
If you have any ideas how to improve this images please feel free to open an issue at https://github.com/Samhamsam/docker-openvpn-bridge/issues.
