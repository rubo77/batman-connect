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

 
    fastd-install.sh

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

[download script](https://raw.githubusercontent.com/ffnord/batman-connect/master/batman-connect)

Achtung
---
Dieses Script ist noch experimentell: Ein Fehler ist, dass es nur einmal funktioniert. Man kann sich dann zwar wieder trennen mit <br>

    batman-connect stop
    
aber meist funktioniert ein erneutes Verbinden erst nach einem Rechner neustart

Alfred installieren
===
http://askubuntu.com/a/426305/34298
