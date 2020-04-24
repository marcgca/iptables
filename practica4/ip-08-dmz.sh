#!/bin/bash
# Marc Gómez
# @marcgca
# isx47797439
# EDT ASIX M11 19-20

# ip-08-DMZ.sh:  DMZ
#     Plantejat el model de DMZ, al readme hi ha les ordres per engegar els containers.
#     xarxaA: hostA1 i hostA2. xarxaB hostB1 i hostB2. xarxaDMZ host dmz1(nethost) dmz2(ldapserver), 
#            dmz3(kserver), dmz4(samba)
#     aplicar les regles que es descriuen al readme:
#         de la xarxaA només es pot accedir del router/fireall als serveis: ssh i daytime(13)
#         de la xarxaA només es pot accedir a l'exterior als serveis web, ssh i daytime(2013)
#         de la xarxaA només es pot accedir serveis que ofereix la DMZ al servei web
#         redirigir els ports perquè des de l'exterior es tingui accés a: 3001->hostA1:80, 
#                3002->hostA2:2013, 3003->hostB1:2080,3004->hostB2:2007
#         S'habiliten els ports 4001 en endavant per accedir per ssh als ports ssh de: hostA1, hostA2,
#             hostB1, hostB2.
#         S'habilita el port 4000 per accedir al port ssh del router/firewal si la ip origen és 
#            del host i26.
#         Els hosts de la xarxaB tenen accés a tot arreu excepte a la xarxaA.

# Netejem les regles i les deixem per defecte
bash ./ip-default.sh

# Activem que el host fagi de router
echo 1 > /proc/sys/net/ipv4/ip_forward

# netA: hostA1 i hostA2. 172.19.0.0
docker run --rm --name hostA1 -h hostA1 --net netA --privileged -d edtasixm11/net18:nethost
docker run --rm --name hostA2 -h hostA2 --net netA --privileged -d edtasixm11/net18:nethost
# netB hostB1 i hostB2.   172.20.0.0
docker run --rm --name hostB1 -h hostB1 --net netB --privileged -d edtasixm11/net18:nethost
docker run --rm --name hostB2 -h hostB2 --net netB --privileged -d edtasixm11/net18:nethost
# xarxaDMZ host dmz1(nethost) dmz2(ldapserver),dmz3(kserver), dmz4(samba) 172.21.0.0
docker run --rm --name dmz1 -h dmz1 --net netDMZ --privileged -d edtasixm11/net18:nethost
docker run --rm --name dmz2 -h dmz2 --net netDMZ --privileged -d edtasixm06/ldapserver:18group
docker run --rm --name dmz3 -h dmz3 --net netDMZ --privileged -d edtasixm11/k18:kserver
docker run --rm --name dmz4 -h dmz4 --net netDMZ --privileged -d edtasixm06/samba:18detach

# Si volguèssim fer NAT de les xarxes internes
# iptables -t nat -A POSTROUTING -s 172.19.0.0/16 -o wlp1s0 -j MASQUERADE
# iptables -t nat -A POSTROUTING -s 172.20.0.0/16 -o wlp1s0 -j MASQUERADE
# iptables -t nat -A POSTROUTING -s 172.21.0.0/16 -o wlp1s0 -j MASQUERADE

# de la xarxaA només es pot accedir del router/firewall als serveis: ssh i daytime(13)
iptables -A FORWARD -s 172.19.0.0/16  -p tcp --dport 22  -j ACCEPT
iptables -A FORWARD -s 172.19.0.0/16  -p tcp --dport 13  -j ACCEPT
iptables -A FORWARD -s 172.19.0.0/16  -p tcp  -j DROP

# de la xarxaA només es pot accedir a l'exterior als serveis web, ssh i daytime(2013)
iptables -t nat -A POSTROUTING -s 172.19.0.0/16 -o wlp1s0 -j MASQUERADE

iptables -A FORWARD -s 172.19.0.0/16 -o wlp1s0 -p tcp --dport 22  -j ACCEPT
iptables -A FORWARD -s 172.19.0.0/16 -o wlp1s0 -p tcp --dport 2013  -j ACCEPT
iptables -A FORWARD -d 172.19.0.0/16 -o wlp1s0 -p tcp --sport 80 -m state --state ESTABLISHED,RELATED -j ACCEPT 
iptables -A FORWARD -d 172.19.0.0/16 -o wlp1s0 -p tcp --sport 443 -m state --state ESTABLISHED,RELATED -j ACCEPT 
iptables -A FORWARD -s 172.19.0.0/16 -o wlp1s0 -p tcp --dport 80  -j ACCEPT
iptables -A FORWARD -s 172.19.0.0/16 -o wlp1s0 -p tcp --dport 443  -j ACCEPT
iptables -A FORWARD -s 172.19.0.0/16 -o wlp1s0 -p tcp  -j DROP

# de la xarxaA només es pot accedir serveis que ofereix la DMZ al servei web
iptables -A FORWARD -d 172.19.0.0/16  -p tcp --sport 80 -m state --state ESTABLISHED,RELATED -j ACCEPT 
iptables -A FORWARD -s 172.19.0.0/16  -p tcp --dport 80  -j ACCEPT
iptables -A FORWARD -s 172.19.0.0/16  -p tcp  -j DROP

# redirigir els ports perquè des de l'exterior es tingui accés a: 
#    3001->hostA1:80, 
#    3002->hostA2:2013, 
#    3003->hostB1:2080,
#    3004->hostB2:2007
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 3001 -j DNAT --to 172.19.0.2:80
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 3002 -j DNAT --to 172.19.0.3.2013
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 3003 -j DNAT --to 172.20.0.2:2080
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 3004 -j DNAT --to 172.20.0.3:2007

# S'habiliten els ports 4001 en endavant per accedir per ssh als ports ssh de: hostA1, hostA2,
#     hostB1, hostB2.
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 4001 -j DNAT --to 172.19.0.2:22
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 4002 -j DNAT --to 172.19.0.3.22
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 4003 -j DNAT --to 172.20.0.2:22
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 4004 -j DNAT --to 172.20.0.3:22

# S'habilita el port 4000 per accedir al port ssh del router/firewal si la ip origen és 
#    del host i26.
iptables -t nat -A PREROUTING -s i26 -p tcp --dport 4000 -j DNAT --to 192.168.1.37:22

# Els hosts de la xarxaB tenen accés a tot arreu excepte a la xarxaA.
iptables -t nat -A POSTROUTING -s 172.20.0.0/16 -o wlp1s0 -j MASQUERADE
iptables -A FORWARD -s 172.20.0.0/16 -d 172.19.0.0/16 -p tcp -j REJECT

