#!/bin/bash
# Marc Gómez
# @marcgca
# isx47797439
# EDT ASIX M11 19-20

# ip-07-port-forwar.sh:  IP/PORT forwarding
#     expliocat que és fer un prerouting que el que fem és DNAT, modificar la adreça i/o port destí.
#     SEMPRE despres del prerouting s’aplica el routing de manera que s’aplicaran les regles input o
#          forward a continuació.
#     exemple de fer port forwarding dels ports 5001, 5002 i 5003 al port 13 de hostA1, hostA2 i
#          el pròpi router. Observar que externament accedim al port 13 de cada host.
#     posar ara una regla forwarding reject del port 13 i veiem que l’accés dels ports 5001 i 5002 
#         es rebutja, perquè després del port forwarding hi ha el routing que aplica forward.
#     treiem la regla forward i posem una regla input reject del port 13. ara és el port 5003
#          el que no funciona, perquè s’aplica input en ser el destí localhost.

# Netejem les regles i les deixem per defecte
bash ./ip-default.sh

# Activem que el host fagi de router
echo 1 > /proc/sys/net/ipv4/ip_forward

# Exemple de fer port forwarding dels ports 5001, 5002 i 5003 al port 13 de hostA1, hostA2 i
# el pròpi router. Observar que externament accedim al port 13 de cada host.

iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 5001 -j DNAT --to 172.19.0.2:13
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 5002 -j DNAT --to 172.19.0.2:13
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 5003 -j DNAT --to 172.19.0.2:13

iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 5001 -j DNAT --to 172.19.0.3:13
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 5002 -j DNAT --to 172.19.0.3:13
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 5003 -j DNAT --to 172.19.0.3:13

# Posar ara una regla forwarding reject del port 13 i veiem que l’accés dels ports 5001 i 5002 
# es rebutja, perquè després del port forwarding hi ha el routing que aplica forward.
iptables -A FORWARD -p tcp --dport 13 -j REJECT

# Treiem la regla forward i posem una regla input reject del port 13. ara és el port 5003
# el que no funciona, perquè s’aplica input en ser el destí localhost.
iptables -nL --line-numbers
iptables -D FORWARD 1

iptables -A INPUT -p tcp --dport 13 -j REJECT