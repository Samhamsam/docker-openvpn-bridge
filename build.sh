#!/bin/bash
#docker rmi ventz/openvpn
docker build --rm=true --force-rm=true -t samhamsam/openvpn-bridge container
