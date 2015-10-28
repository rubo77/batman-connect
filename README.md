batman-connect
==============

Connect to your Freifunk community as node with your local computer

German README
=============

So einfach kann man seinen Laptop in das Freifunk-Netz als Knoten mit integrieren.
(Unter Ubuntu 12.04 bis erfolgreich 14.04 getestet)

*TODO: unter arch lässt sich das batman kernel-Modul nicht einfach kompilieren*

Außerdem konfiguriert dieses Script den eth0-Ausgang so um (wenn vorhanden), dass man **über den Netzwerk-Ausgang an deinem Rechner Internet an weitere Geräte freigeben** kann.

Installation
===

Es werden die Pakete `batctl` für batman-adv und `bridge-utils` für `brctl`

    sudo apt-get install batctl bridge-utils

Neuere Batman Version aus Repo
===

Erstelle die Datei `/etc/apt/sources.list.d/batman-adv-universe-factory.net.list` mit dem repository https://projects.universe-factory.net/projects/fastd/wiki für die neueste version:
 
	sudo bash -c 'echo "deb http://repo.universe-factory.net/debian/ sid main">/etc/apt/sources.list.d/batman-adv-universe-factory.net.list'
	gpg --recv-keys 0x16EF3F64CB201D9C
	gpg --export 0x16EF3F64CB201D9C|sudo apt-key add -
	# TODO: Hier sollte man aus Sicherheitsaspekten noch den Fingerprint auf Korrektheit überprüfen
	sudo apt-get update
	sudo apt-get install batman-adv-dkms

Wenn du den Fehler erhälst

	Error! Module version 2013.4.0 for batman-adv.ko
	is not newer than what is already found in kernel 3.14.1-031401-generic (2014.1.0).
	You may override by specifying --force.


Dann müsste dkms mit `--force` aufgerufen werden, da dies aber zur zeit auch nicht hilft, 
muss bis dies gefixt ist das Modul von Hand kopiert werden:

	sudo cp /var/lib/dkms/batman-adv/kernel-$(uname -r)-$(uname -i)/module/batman-adv.ko /lib/modules/$(uname -r)/kernel/net/batman-adv/batman-adv.ko

Achtung
---
Dies muss nach jedem Kernel-update neu ausgeführt werden, da die Datei `/lib/modules/$(uname -r)/kernel/net/batman-adv/batman-adv.ko` jedes mal neu überschrieben wird.

Kernelmodul laden
===

	sudo modprobe batman-adv

Version prüfen
===

	sudo batctl -v

Nicht alle Batman Versionen sind kompatibel - siehe: http://www.open-mesh.org/projects/batman-adv/wiki/Compatversion 
Du brauchst **genau die Version 2013.4.0**:

	batctl debian-2013.4.0-2 [batman-adv: 2013.4.0]

 
Start-Script erstellen
===

Um sich mit der *ESSID* `02:ca:ff:ee:ba:be` auf der Schnittstelle `wlan0` mit der *BSSID* `02:ca:ff:ee:ba:be` zu verbinden erstelle folgendes script und nenne es <br>

    /usr/local/bin/batman-connect

[download script](https://raw.githubusercontent.com/rubo77/batman-connect/master/batman-connect)

Achtung
---
Dieses Script ist noch experimentell: Ein Fehler ist, dass es nur einmal funktioniert. Man kann sich dann zwar wieder trennen mit <br>

    batman-connect stop
    
aber meist funktioniert ein erneutes Verbinden erst nach einem Rechner neustart

Alfred installieren
===
http://askubuntu.com/a/426305/34298
