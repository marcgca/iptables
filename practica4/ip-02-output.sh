#!/bin/bash
# Marc Gómez
# @marcgca
# isx47797439
# EDT ASIX M11 19-20

# ip-02-output.sh: regles bàsiques de output
#     accedir a qualsevol host/port extern
#     accedir a qualsevol port extern 13.
#     accedir a qualsevol port 2013 excepte el del i26.
#     denegar l’accés a qualsevol port 3013, però permetent accedir al 3013 de i26.
#     permetre accedir al port 4013 de tot arreu, excepte dels hosts de la xarxa hisx2, 
#     però si permetent accedir al port 4013 del host i26.
#     xapar l’accés a qualsevol port 80, 13, 7.
#     no permetre accedir als hosts i26 i i27.
#     no permetre accedir a les xarxes hisx1 i hisx2.
#     no permetre accedir a la xarxa hisx2 excepte per ssh.

# Netejem les regles i les deixem per defecte
bash ./ip-default.sh

# Accedir a qualsevol host/port extern
iptables -A OUTPUT -j ACCEPT

# Accedir a qualsevol port extern 13.
iptables -A OUTPUT -p tcp --dport 13 -j ACCEPT

# Accedir a qualsevol port 2013 excepte el del i26.
iptables -A OUTPUT -d i26 -p tcp --dport 2013 -j DROP
iptables -A OUTPUT -p tcp --dport 2013 -j ACCEPT

# Denegar l’accés a qualsevol port 3013, però permetent accedir al 3013 de i26.
iptables -A OUTPUT -d i26 -p tcp --dport 3013 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 3013 -j DROP

# Permetre accedir al port 4013 de tot arreu, excepte dels hosts de la xarxa hisx2, 
# però si permetent accedir al port 4013 del host i26.
iptables -A OUTPUT -d i26 -p tcp --dport 4013 -j ACCEPT
iptables -A OUTPUT -d 192.168.2.0/24 -p tcp --dport 4013 -j DROP
iptables -A OUTPUT -p tcp --dport 4013 -j ACCEPT

# Xapar l’accés a qualsevol port 80, 13, 7.
iptables -A OUTPUT -p tcp --dport 80 -j DROP
iptables -A OUTPUT -p tcp --dport 13 -j DROP
iptables -A OUTPUT -p tcp --dport 7 -j DROP

# No permetre accedir als hosts i26 i i27.
iptables -A OUTPUT -d i26 -j DROP
iptables -A OUTPUT -d i27 -j DROP

# No permetre accedir a les xarxes hisx1 i hisx2.
iptables -A OUTPUT -d 192.168.3.0/24 -j DROP
iptables -A OUTPUT -d 192.168.2.0/24 -j DROP

# No permetre accedir a la xarxa hisx2 excepte per ssh.
iptables -A OUTPUT -d 192.168.2.0/24 -j DROP
iptables -A OUTPUT -d 192.168.2.0/24 -p tcp --dport 22 -j ACCEPT