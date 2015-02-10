#! /bin/bash

if [ "$(whoami &2>/dev/null)" != "root" ] && [ "$(id -un &2>/dev/null)" != "root" ] ; then
  echo "You must be root to run this script!"; echo "use 'sudo !!'"; exit 1
fi

FASTD_PORT=10035
MESH_CODE=ffki
MESH_MTU=1492


## generate a MAC address for bat0
MAC=$(od /dev/urandom -w6 -tx1 -An|sed -e 's/ //' -e 's/ /:/g'|head -n 1)


# PPA for fastd and batman-adv
echo "deb http://repo.universe-factory.net/debian/ sid main" > /etc/apt/sources.list.d/batman-adv-universe-factory.net.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 16EF3F64CB201D9C
apt-get update

# fastd:

# wheezy-Backports for libjson-c2 ( fastd >= 15)
echo "deb http://http.debian.net/debian wheezy-backports main" > /etc/apt/sources.list.d/wheezy-backports.list
gpg --keyserver pgpkeys.mit.edu --recv-key 16EF3F64CB201D9C
gpg -a --export 16EF3F64CB201D9C | apt-key add -

# alfred and alfred-json
wget http://download.opensuse.org/repositories/home:fusselkater:/ffms/Debian_7.0/Release.key -O - | apt-key add - 
apt-get update
apt-get install -y fastd

useradd --system --no-create-home --shell /bin/false fastd
mkdir /var/log/fastd

if [ ! -f /etc/fastd/secret.conf ]; then
	# fasd-key generieren
	fastd --generate-key > /tmp/fastdkeys.tmp
	echo 'secret "'$(cat /tmp/fastdkeys.tmp|grep Secret|sed "s/Secret: //g")'";' > /etc/fastd/secret.conf
	echo 'key "'$(cat /tmp/fastdkeys.tmp|grep Public|sed "s/Public: //g")'";' > /etc/fastd/public.conf
fi

BAT_INTERFACE=bat-${MESH_CODE}
DEFAULT_ROUTE=$(route -n|grep UG|xargs|cut -f 2 -d" ")
mkdir -p /etc/fastd/${MESH_CODE}/
cat > /etc/fastd/${MESH_CODE}/fastd.conf  << EOF
log to syslog level error;
log to syslog as "fastd-debug" level debug;
interface "${BAT_INTERFACE}";
mode tap;
method "salsa2012+umac"; # since fastd v15
method "salsa2012+gmac";
method "xsalsa20-poly1305"; # deprecated
bind any:${FASTD_PORT};
hide ip addresses yes;
hide mac addresses yes;
include "/etc/fastd/secret.conf";
mtu ${MESH_MTU}; # 1492 - IPv{4,6} Header - fastd Header...
status socket "/var/run/fastd-status.${MESH_CODE}.sock";
include peers from "peers";
on up "
  set -x
  modprobe batman-adv
  ip tuntap add dev ${BAT_INTERFACE} mode tap
  #ip link set address ${MAC} dev \$INTERFACE
  /usr/sbin/batctl -m ${BAT_INTERFACE} if add \$INTERFACE
  #ip link set address ${MAC} dev ${BAT_INTERFACE}
  ip link set up ${BAT_INTERFACE}
  ip link set up dev \$INTERFACE
  service alfred start ${BAT_INTERFACE}
";
on establish "
  dhclient ${BAT_INTERFACE}
  ip route add default via ${DEFAULT_ROUTE} #Privates GW
";
EOF

mkdir -p /etc/fastd/${MESH_CODE}/peers
# get keys from a freifunk router in your community and use
# cat /etc/fastd/ffki-mesh-vpn/peers/*
cat > /etc/fastd/${MESH_CODE}/peers/connectionPartner << EOF
key "6871220dc77ab508dc45107fd32db8874a40f0ea1ed52985aa798bd603a2ac68";
remote ipv4 "freifunk.in-kiel.de" port 10000;
key "65db8bff947e7c02ef7e152e73fb17c39ee9cfea91d047cb7a063ecb1eb7dd88";
remote ipv4 "vpn1.freifunk.in-kiel.de" port 10000;
key "b8f16e80846b96d840d6fb1db79a5216ae5de27994ea5c4e96f4fb86a6bb805c";
remote ipv4 "vpn2.freifunk.in-kiel.de" port 10000;
key "c986eff66227bf0181d07fcaa1624def8895b6ed99e0effd0015d7bd5ef89ea6";
remote ipv4 "vpn3.freifunk.in-kiel.de" port 10000;
key "3895852c04374cce431ef222086cfb5be22e62b3d39ef03ca4f130adea5d6b4f";
remote ipv4 "vpn4.freifunk.in-kiel.de" port 10000;
key "b04def1d7959c30324d99736cfb67fb6addbe0c383f9b7fc5b82a87f64969957";
remote ipv4 "vpn5.freifunk.in-kiel.de" port 10000;
key "48026a947c62a55128ff4bd2532c053b3da72c48f914329fd5eb3ca36b21d048";
remote ipv4 "vpn6.freifunk.in-kiel.de" port 10000;
key "0815c3c22c243719d21f6b7ca8f2f540e169d2aee1fc1b644de5872b35bc3c74";
remote ipv4 "vpn7.freifunk.in-kiel.de" port 10000;
key "888ae5499eb0efad973e3cc942d67479b15f4591a39f01624a7ec2e972c8b753";
remote ipv4 "vpn8.freifunk.in-kiel.de" port 10000;
EOF

# start fastd
fastd --config /etc/fastd/${MESH_CODE}/fastd.conf

#install bridge utils for networking; kernel headers and build-essential for make
apt-get install -y bridge-utils build-essential linux-headers-$(uname -r)


: "install batman"
# keine offizielle Batman-Adv Version verwenden, Clients müssen die Optimierte Version aus dem Gluon Repo verwenden.
cd /tmp/
wget https://github.com/freifunk-gluon/batman-adv-legacy/archive/master.zip
rm -Rf batman-adv-legacy-master
unzip master.zip
cd /tmp/batman-adv-legacy-master/
make
make install

: "add batman-adv in modules if not exists"
LINE="batman-adv"
FILE=/etc/modules
grep -q "$LINE" "$FILE" || echo "$LINE" >> "$FILE"

apt-get install -y batctl