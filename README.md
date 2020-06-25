# Required "DATA" directory for OpenVPN

This container assumes you have a "/data" (or like) directory with your server config and certs like so:

```
/data/certs:
  ca.crt
  dh.pem
  server.crt
  server.key
  ta.key (technically "optional" - in reality a must for security)
  crl.pem (optional - revoke list)

/data:
  server.conf
```


## Server Config
```
port 1194
proto udp
dev tap0
ca certs/ca.crt
cert certs/chserver.crt
key certs/chserver.key  # This file should be kept secret
dh none
ecdh-curve secp521r1
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

# How to run the OpenVPN Docker Container?
```
docker run -it -d --restart=always --name=openvpn  -p 1194:1194/udp --cap-add=NET_ADMIN -v /home/<name>/data/:/etc/openvpn --network=host samhamsam/openvpn-bridge
```
