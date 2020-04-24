#!/bin/bash
# Marc Gómez
# @marcgca
# isx47797439
# EDT ASIX M11 19-20

# ip-default.sh:
#     fer flush de totes les regles.
#     definir política per defecte accept.
#     obrir al lo i la pròpia ip les connexions locals.
#     llistar les regles

# Executar amb sudo o root

# Fer flush de totes les regles
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

# definir política per defecte accept.
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

# obrir al lo i la pròpia ip les connexions locals.
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# pròpia ip
iptables -A INPUT -s 192.168.1.37/24 -j ACCEPT
iptables -A OUTPUT -d 192.168.1.37/24 -j ACCEPT

# llistar les regles
# iptables -L -n
