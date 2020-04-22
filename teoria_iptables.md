# Teoria IPtables

# Conceptes bàsics

* `Socket`: un socket és el resultat de `(IP origen + Port origen) + (IP destí + Port destí)`.

* `Connexió`: un socket descriu de manera **única** una connexió.

* `Comunicació`: per establir una *comunicació* **sempre** hi ha dos camins (dues **connexions**) una **d'anada** i una de **tornada**.
  
  * `Anada`: de l'origen al destí  **Origen -> Destí**
  
  * `Tornada`: la **resposta** del destí a l'origen  **Destí -> Origen**

* `Punt de vista`: agafem com a punt de vista el host/router en el que estem escrivint les **regles del firewall**. Així doncs, des del punt de vista d'aquest host tenim (*a nivell bàsic*):
  
  * `Input`: el tràfic **destinat a aquest host**
  
  * `Output`: el tràfic que **s'origina en aquest host**
  
  * `Forward` (quan el host és un router): el tràfic que **creua el host**
    
    ![](/home/marc/.var/app/com.github.marktext.marktext/config/marktext/images/2020-04-21-18-21-14-image.png)

## Input

El tràfic *input* és tot aquell que està **destinat** al *host-aula*. NO que passi, sinó destinat al host.

Qualsevol host que contacti com a destí al *host-aula* (quan el tràfic arriba al *host-aula*) és tràfic **input** (i se li aplicaràn les regles d'input).

Poden ser connexions que provenen de la xarxa externa (internet), de les xarxes privades internes, i fins i tot por ser una pròpia connexió local de *host-aula* a *host-aula*.

Típics exemples de filtrar input:

* Permetre o denegar el tràfic segons el **servei (port)** del *host-aula* al que intenta accedir la connexió entrant.

* Permetre o denegar el tràfic segons **l'adreça IP** del **host origen**.

* Permetre o denegar el tràfic segons **l'adreça IP** de la **xarxa origen**.

* Combinacions de les regles anterior tipus **tots poden, però els d'aquesta xarxa no, però aquest/s en concret (de la xarxa negada) sí**.
  
  O a l'inrevés: **tots negats, però aquesta xarxa sí, però aquest/s en concret (de la xarxa permesa) no**.
  
  ```bash
  # Exemples regles input
  ```

## Output

El tràfic *output* és tot aquell **generat** en el *host-aula*, és a dir, tot aquell tràfic que **'surt'** del host. Pot estar destinat a internet, xarxes privades locals com fins i tot al propi host, segueix sent tràfic **output**.

Típics exemples de filtrar 

* Permetre o denegar el tràfic segons el **servei (port)** del host al que volem accedir.

* Permetre o denegar el tràfic segons **l'adreça IP** del **host destí**.

* Permetre o denegar el tràfic segons **l'adreça IP** de la **xarxa destí**.
  
  ```bash
  # Exemple regles output
  ```

## Established

Quan estem parlant de **TCP** sabem que hi ha una connexió inicial de tres vies i que hi ha un **establiment** de connexió.

En el cas de tcp es poden establir regles verificant que el tràfic sigui **established** i **related**.

Per exemple, no es permet tràfic **input** del protocol http al *host-aula* però sí navegar per internet. Això significa que es permet tràfic de sortida **output** cap a servidors d'internet però només es permet tràfic d'entrada **input** de tipus http si **són respostes** al tràfic generat **established/related**. Si són peticions de tràfic nou entrant **NO** es permet.

### NAT

El que fa la **NAT** (*Network Address Translation*) és enmascarar les adreces IP **privades** de les xarxes locals per sortir a l'exterior usant l'adreça **pública del router** (o el host si el transformem en un router).

Per a transformar un host en router simplement hem de posar el bit del kernel de *forwarding* a 1.

Per exemple, els hosts *A1* i *A2* volen connectar-se a Google però no poden (tenen les regles output capades), fem que passi pel router (*host-aula*):

```bash
Ip:port origen ---- > ip:port destí 
A1:dinàmic7 ---- > google:80
A1:dinàmic9 ---- > google:80
A2:dinàmic3 ---- > google:80
                        // Aplicant NAT //
ip:port origen ---- > ip:port destí
host-aula:dinàmic1 ---- > google:80
host-aula:dinàmic2 ---- > google:80
host-aula:dinàmic3 ---- > google:80
```

En aquest cas, el servidor de Google respondrà **al router** i aquest (amb la taula de traslacions NAT on té qui ha demanat què) li reenvia (*forwarding*) a qui hagi fet la petició inicial. El servidor de Google desconeix l'existència d'aquests hosts privats.

```bash
Ip:port origen ---- > ip:port destí 
google:80 ---- > host-aula:dinàmic1
google:80 ---- > host-aula:dinàmic2
google:80 ---- > host-aula:dinàmic3
                        // Aplicant NAT //
ip:port origen ---- > ip:port destí
google:80 ---- > A1:dinàmic7
google:80 ---- > A1:dinàmic9
google:80 ---- > A2:dinàmic3
```

Quan el router detecta que no és ell el destí, sino Google, aplica el **POSTROUTING SNAT** modificant l'ip:port origen posant-hi el seu i anotant-ho a la **taula NAT**. Quan el servidor de Google respon el router aplica el **PREROUTING DNAT** abans que les regles input, i ell sol ja torna a canviar les adreces:ports corresponents, aplicant les regles **forward**.

Resumint, només hi ha un tràfic de sortida i un altre de tornada, el del host al servidor de google ( el router deixa passar sense aplicar les regles *input* /*output*  com si anés dirigit a ell)


