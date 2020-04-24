#!/bin/bash
# Marc Gómez
# @marcgca
# isx47797439
# EDT ASIX M11 19-20

# ip-09-DMZ2.sh:  DMZ amb servidors nethost, ldap, kerberos i samba
#     (1) des d'un host exterior accedir al servei ldap de la DMZ. Ports 389, 636.
#     (2) des d'un host exterior, engegar un container kclient i obtenir un tiket kerberos del servidor de la DMZ. Ports: 88, 543, 749.
#     (3) des d'un host exterior muntar un recurs samba del servidor de la DMZ.

# Netejem les regles i les deixem per defecte
bash ./ip-default.sh

# Activem que el host fagi de router
echo 1 > /proc/sys/net/ipv4/ip_forward

# Fent servir els contàiners executats a la pràctica anterior

# (1) des d'un host exterior accedir al servei ldap de la DMZ. Ports 389, 636.
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 389 -j DNAT --to 172.21.0.3:389
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 636 -j DNAT --to 172.21.0.3:636

# [marc@localhost ~]$ ldapsearch -x -LLL -b 'dc=edt,dc=org' -h 192.168.88.2 dn
# dn: dc=edt,dc=org
# dn: ou=grups,dc=edt,dc=org
# dn: ou=usuaris,dc=edt,dc=org
# dn: cn=hisx1,ou=grups,dc=edt,dc=org
# ...

# (2) des d'un host exterior, engegar un container kclient i obtenir un tiket 
#    kerberos del servidor de la DMZ. Ports: 88, 543, 749.
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 88 -j DNAT --to 172.21.0.4:88
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 543 -j DNAT --to 172.21.0.4:543
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 749 -j DNAT --to 172.21.0.4:749

# [marc@localhost ~]$ docker run --rm --name khost -h khost --net host -it marcgc/k19:khostpl
# [root@khost docker]# kinit anna
# Password for anna@EDT.ORG: 
# [root@khost docker]# klist
# Ticket cache: FILE:/tmp/krb5cc_0
# Default principal: anna@EDT.ORG

# (3) des d'un host exterior muntar un recurs samba del servidor de la DMZ.

iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 139 -j DNAT --to 172.21.0.5:139
iptables -t nat -A PREROUTING -i wlp1s0 -p tcp --dport 445 -j DNAT --to 172.21.0.5:445

# [marc@localhost ~]$ smbclient //SAMBA/public -I 192.168.1.37
# Enter anna@EDT.ORG's password: 
# Anonymous login successful
# Try "help" to get a list of possible commands.
# smb: \> ls
#   .                                   D        0  Sat Apr 18 10:33:41 2020
#   ..                                  D        0  Sat Apr 18 10:34:24 2020
#   install.sh                          A      572  Sat Apr 18 10:33:41 2020
#   smb.conf                            N     1400  Sat Apr 18 10:33:41 2020
#   README.md                           N     1909  Sat Apr 18 10:33:41 2020
#   startup.sh                          A      154  Sat Apr 18 10:33:41 2020
#   Dockerfile                          N      379  Sat Apr 18 10:33:41 2020
