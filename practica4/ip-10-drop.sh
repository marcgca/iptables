#!/bin/bash
# Marc Gómez
# @marcgca
# isx47797439
# EDT ASIX M11 19-20

# ip-10-drop.sh:  DROP política drop per defecte

# Implementar DROP per defecte a un host de l’aula i que funcioni normalment. Exemple fitxer https://drive.google.com/open?id=1vqjOJfLSt0McfJg7AuIRdqwR_6dbCR_X 
# A tenir en compte en el DROP:
#     dns 53
#     dhclient (68)
#     ssh (22)
#     rpc 111, 507
#     chronyd 123, 371
#     cups 631
#     xinetd 3411
#     postgresql 5432
#     x11forwarding 6010, 6011
#     avahi 368
#     alpes 462
#     tcpnethaspsrv 475
#     pxe 761
# permetre servei local de: echo-stream, daytime-stream, telnet, pop3, imap, tftp
# accedir als serveis externs de: echo-stream, ssh, tftp (no entenc on es troben aquests serveis)

# Fer flush de totes les regles
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

# definir política per defecte accept.
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# obrir al lo i la pròpia ip les connexions locals.
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# pròpia ip
iptables -A INPUT -s 192.168.1.37/24 -j ACCEPT
iptables -A OUTPUT -d 192.168.1.37/24 -j ACCEPT

# dns 53
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --sport 53 -j ACCEPT

# dhclient (68)
iptables -A INPUT -p udp --dport 68 -j ACCEPT
iptables -A OUTPUT -p udp --sport 68 -j ACCEPT

# ssh (22)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT

# rpc 111, 507
iptables -A INPUT -p tcp --dport 111 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 111 -j ACCEPT

iptables -A INPUT -p tcp --dport 507 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 507 -j ACCEPT

# chronyd 123, 371
iptables -A INPUT -p udp --dport 123 -j ACCEPT
iptables -A OUTPUT -p udp --sport 123 -j ACCEPT

iptables -A INPUT -p udp --dport 371 -j ACCEPT
iptables -A OUTPUT -p udp --sport 371 -j ACCEPT

# cups 631
iptables -A INPUT -p tcp --dport 631  -j ACCEPT
iptables -A OUTPUT -p tcp --sport 631  -j ACCEPT

# xinetd 3411
iptables -A INPUT -p tcp --dport 3411 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 3411 -j ACCEPT

# postgresql 5432
iptables -A INPUT -p tcp --dport 5432 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 5432 -j ACCEPT

# x11forwarding 6010, 6011
iptables -A INPUT -p tcp --dport 6010 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 6010 -j ACCEPT

iptables -A INPUT -p tcp --dport 6011 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 6011 -j ACCEPT

# avahi 368
iptables -A INPUT -p udp --dport 368 -j ACCEPT
iptables -A OUTPUT -p udp --sport 368 -j ACCEPT

# alpes 462
iptables -A INPUT -p udp --dport 463 -j ACCEPT
iptables -A OUTPUT -p udp --sport 463 -j ACCEPT

# tcpnethaspsrv 475
iptables -A INPUT -p udp --dport 475 -j ACCEPT
iptables -A OUTPUT -p udp --sport 475 -j ACCEPT

# pxe 761
iptables -A INPUT -p tcp --dport 761 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 761 -j ACCEPT

# permetre servei local de: echo-stream, daytime-stream, telnet, pop3, imap, tftp
# echo-stream
iptables -A INPUT -p tcp --dport 7 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 7 -j ACCEPT

# daytime-stream
iptables -A INPUT -p tcp --dport 13 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 13 -j ACCEPT

# telnet
iptables -A INPUT -p tcp --dport 23 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 23 -j ACCEPT

# pop3/xifrat
iptables -A INPUT -p tcp --dport 110 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 110 -j ACCEPT

iptables -A INPUT -p tcp --dport 995 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 995 -j ACCEPT

# imap/imap3/imaps
iptables -A INPUT -p tcp --dport 143 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 143 -j ACCEPT

iptables -A INPUT -p tcp --dport 220 -j ACCEPT
iptables -A OUTPUT  -p tcp --sport 220 -j ACCEPT

iptables -A INPUT -p tcp --dport 993 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 993 -j ACCEPT

# tftp
iptables -A INPUT -p udp --dport 69 -j ACCEPT
iptables -A OUTPUT -p udp --sport 69 -j ACCEPT
