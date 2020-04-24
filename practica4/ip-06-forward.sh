#!/bin/bash
# Marc Gómez
# @marcgca
# isx47797439
# EDT ASIX M11 19-20

# ip-06-forwar.sh:  Forwarding
#     forwarding: Usant el model anterior de nat aplicar regles de tràfic de xarxaA a 
#     l’exterior i de xarxaA a xarxaB. 
#     Filtrar per port i per destí.
#     xarxaA no pot accedir xarxab
#     xarxaA no pot accedir a B2.
#     host A1 no pot connectar host B1
#     xarxaA no pot accedir a port 13.
#     xarxaA no pot accedir a ports 2013 de la xarxaB
#     xarxaA permetre navegar per internet però res més a l'exterior
#     xarxaA accedir port 2013 de totes les xarxes d'internet excepte de la xarxa hisx2
#     evitar que es falsifiqui la ip de origen: SPOOFING

# Netejem les regles i les deixem per defecte
bash ./ip-default.sh

# Activem que el host fagi de router
echo 1 > /proc/sys/net/ipv4/ip_forward

# xarxaA 172.19.0.0 hostA1 .2 hostA2 .3
# xarxaB 172.20.0.0 hostB1 .2 hostB2 .3

# forwarding: Usant el model anterior de nat aplicar regles de tràfic de xarxaA a 
# l’exterior i de xarxaA a xarxaB. 
iptables -t nat -A POSTROUTING -s 172.19.0.0/16 -o wlp1s0 -j MASQUERADE

# Filtrar per port i per destí.
# XarxaA no pot accedir xarxab
iptables -A FORWARD -s 172.19.0.0/16 -d 172.20.0.0/16 -j REJECT

# XarxaA no pot accedir a hostB2.
iptables -A FORWARD -s 172.19.0.0/16 -d 172.20.0.3 -j REJECT

# host hostA1 no pot connectar host hostB1
iptables -A FORWARD -s 172.19.0.2 -d 172.20.0.2 -j REJECT

# XarxaA no pot accedir a port 13.
iptables -A FORWARD -s 172.19.0.0/16 -p tcp --dport 13 -j REJECT

# XarxaA no pot accedir a ports 2013 de la xarxaB
iptables -A FORWARD -s 172.19.0.0/16 -d 172.20.0.0/16 -p tcp --dport 2013 -j REJECT

# XarxaA permetre navegar per internet però res més a l'exterior
iptables -A FORWARD -d 172.19.0.0/16 -p tcp --sport 80 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -d 172.19.0.0/16 -p tcp --sport 443 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s 172.19.0.0/16 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -s 172.19.0.0/16 -p tcp --dport 443 -j ACCEPT
iptables -A FORWARD -s 172.19.0.0/16 -p tcp -j REJECT

# XarxaA accedir port 2013 de totes les xarxes d'internet excepte de la xarxa hisx2
iptables -A FORWARD -s 172.19.0.0/16 -d 192.168.2.0/24 -p tcp --dport 2013 -o wlp1s0 -j REJECT
iptables -A FORWARD -s 172.19.0.0/16 -p tcp --dport 2013 -o wlp1s0 -j ACCEPT

# Evitar que es falsifiqui la ip de origen: SPOOFING
iptable -A FORWARD ! -s 172.19.0.0/16 -i wlp1s0 -j DROP