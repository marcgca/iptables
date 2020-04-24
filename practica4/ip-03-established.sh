#!/bin/bash
# Marc Gómez
# @marcgca
# isx47797439
# EDT ASIX M11 19-20

# ip-03-established.sh: regles tràfic RELATED, ESTABLISHED
#     concepte de  “navegar per internet” → accedir a qualsevol servidor web extern i permetre la ‘resposta’.
#     configurar que sigui un servei web que accepta peticions i només permet respostes relacionades.

# Netejem les regles i les deixem per defecte
bash ./ip-default.sh

# Accedir a qualsevol servidor web extern i permetre la ‘resposta’.
iptables -A OUTPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --sport 80 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A OUTPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --sport 443 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A INPUT -p tcp --dport 80 -j DROP
iptables -A INPUT -p tcp --dport 443 -j DROP

# Configurar que sigui un servei web que accepta peticions i només permet respostes relacionades.
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --sport 80 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --sport 443 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A OUTPUT -p tcp --dport 80 -j DROP
iptables -A OUTPUT -p tcp --dport 443 -j DROP