#!/bin/bash
# Marc Gómez
# @marcgca
# isx47797439
# EDT ASIX M11 19-20

# ip-04-icmp.sh:  ICPM (ping request(8) reply(0))
#     No permetre fer pings cap a l'exterior
#     No podem fer pings cap al i26
#     No permetem respondre als pings que ens facin
#     No permetem rebre respostes de ping


# Netejem les regles i les deixem per defecte
bash ./ip-default.sh

# No permetre fer pings cap a l'exterior
# --icmp-type 8 és echo request
iptables -A OUTPUT -p icmp --icmp-type 8 -j DROP

# No podem fer pings cap al i26
iptables -A OUTPUT -d i26 -p icmp --icmp-type 8 -j DROP

# No permetem respondre als pings que ens facin
iptables -A INPUT -p icmp --icmp-type 8 -j DROP

# No permetem rebre respostes de ping
# --icmp-type 0 és echo reply
iptables -A INPUT -p icmp --icmp-type 0 -j DROP