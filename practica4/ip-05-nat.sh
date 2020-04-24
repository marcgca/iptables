#!/bin/bash
# Marc Gómez
# @marcgca
# isx47797439
# EDT ASIX M11 19-20

# ip-05-nat.sh:  NAT
#     Activar NAT per a les dues xarxes privades locals xarxaA i xarxaB. 
#     Verificar que tornen a tenir connectivitat a l’exterior.

# Netejem les regles i les deixem per defecte
bash ./ip-default.sh

# Activem que el host fagi de router
echo 1 > /proc/sys/net/ipv4/ip_forward

# Activar NAT per a les dues xarxes privades locals xarxaA i xarxaB. 
# xarxaA 172.19.0.0
# xarxaB 172.20.0.0
iptables -t nat -A POSTROUTING -s 172.19.0.0/16 -o wlp1s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.20.0.0/16 -o wlp1s0 -j MASQUERADE