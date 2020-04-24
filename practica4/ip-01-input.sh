#!/bin/bash
# Marc Gómez
# @marcgca
# isx47797439
# EDT ASIX M11 19-20

# ip-01-input.sh: regles bàsiques de input
#     en el host local s’han obert els ports 80 i redirigit a ell els 2080, 3080, 4080, 5080. 
# Tots amb xinetd.
#     port 80 obert a tothom
#     port 2080 tancat a tothom (reject)
#     port 2080 tancat a tothom (drop)
#     port 3080 tancat a tothom però obert al i26
#     port 4080 obert a tohom però tancat a i26
#     port 5080 tancat a tothom, obert a hisx2 (192.168.2.0/24) i tancat a i26.

# Netejem les regles i les deixem per defecte
bash ./ip-default.sh

# Port 80 obert a tothom
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Port 2080 tancat a tothom (reject)
iptables -A INPUT -p tcp --dport 2080 -j REJECT 

# Port 2080 tancat a tothom (drop)
iptables -A INPUT -p tcp --dport 2080 -j DROP

# Port 3080 tancat a tothom però obert al i26
iptables -A INPUT -s i26 -p tcp --dport 3080 -j ACCEPT
iptables -A INPUT -p tcp --dport 3080 -j DROP

# Port 4080 obert a tohom però tancat a i26
iptables -A INPUT -s i26 -p tcp --dport 4080 -j DROP
iptables -A INPUT -p tcp --dport 4080 -j ACCEP

# Port 5080 tancat a tothom, obert a hisx2 (192.168.2.0/24) i tancat a i26.
iptables -A INPUT -s i26 -p tcp --dport 5080 -j DROP
iptables -A INPUT -s 192.168.2.0/24 -p tcp --dport 5080 -j ACCEPT
iptables -A INPUT -p tcp --dport 5080 -j DROP