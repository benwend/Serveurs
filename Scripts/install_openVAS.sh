#!/bin/bash
#
################################################################################
#
# Author  : benwend <benjamin.wend+git@gmail.com>
# Date    : 15/03/2016
# Version : 0.7
#
################################################################################
#
# DOC :
#	lab_-_openvas.pdf
#	http://www.openvas.org/install-source.html
#	https://github.com/ChrisFernandez/openvas_install/blob/master/install_openvas.sh
#	http://proturk.com/blog/install-openvas-8-on-debian-8-jessie/
#
################################################################################
#
# 11/03/2016	benwend		Initial release (v0.1)
# 12/03/2016	benwend		Create 'install' function && add page ID (v0.2)
# 12/03/2016	benwend		Test if the directory '/opt/openvas' exists (v0.3)
# 12/03/2016	benwend		Fix bugs (v0.4)
# 12/03/2016	benwend		DL CLI-1.4.2 : Bug sur Debian 8 avec 1.4.3
# 13/03/2016	benwend		Init OpenVAS (v0.5)
# 14/03/2016	benwend		Add WMI lib
# 14/03/2016	benwend		Fix many bugs
# 14/03/2016	benwend		Test if the user is root
# 15/03/2016	benwend		Add option --wget in openvas-nvt-sync (v0.6)
# 15/03/2016	benwend		Fix good options on patch
# 15/03/2016	benwend		Fixbug in test root
# 15/03/2016	benwend		Push installation nmap in a fct
# 15/03/2016	benwend		Sed config on redis-server
# 15/03/2016	benwend		Sed config on wml_split
# 15/03/2016	benwend		Add function clear
# 15/03/2016	benwend		Push installation packages in a fct
# 15/03/2016	benwend		Add Gnupg (v0.7)
#
################################################################################

## CONFIGURATION
SMBID="1975"
SMB="openvas-smb-1.0.1"
LIBID="2291"
LIBRARIES="openvas-libraries-8.0.7"
SCANID="2266"
SCANNER="openvas-scanner-5.0.5"
MANID="2295"
MANAGER="openvas-manager-6.0.8"
GSAID="2299"
GSA="greenbone-security-assistant-6.0.10"
CLID="2141"
CLI="openvas-cli-1.4.2" # BUG de la 1.4.3 sur debian 8
WMI="wmi-1.3.14"
NMAP="nmap-5.51.6" # Supported bu NMAP

DIR="/opt/openvas"

# Installation of NMAP
#
# Usage : install_nmap
function install_nmap() {
	cd $DIR

	if [ ! -f "$NMAP" ]; then
		if [ ! -f "$NMAP.tgz" ]; then
			wget http://nmap.org/dist/$NMAP.tgz
		fi
		tar xvf $NMAP.tgz
	fi

	cd $NMAP
	./configure
	make
	make install

	cd $DIR
}

# installation of lib WMI
#
# Usage : install_wmi
function install_wmi() {
	cd $DIR

	if [ ! -f "$WMI" ]; then
		if [ ! -f "$WMI.tar.bz2" ]; then
			wget http://openvas.org/download/wmi/$WMI.tar.bz2
		fi
		tar -xf $WMI.tar.bz2
	fi

	cd $WMI

	if [ ! -f "openvas-$WMI.patch" ]; then
		wget http://openvas.org/download/wmi/openvas-$WMI.patch
		wget http://openvas.org/download/wmi/openvas-$WMI.patch2
		wget http://openvas.org/download/wmi/openvas-$WMI.patch3
		wget http://openvas.org/download/wmi/openvas-$WMI.patch3v2
		wget http://openvas.org/download/wmi/openvas-$WMI.patch4
		wget http://openvas.org/download/wmi/openvas-$WMI.patch5
	fi

	patch -p1 -f < openvas-$WMI.patch
	patch -p1 -f < openvas-$WMI.patch2
	patch -p1 -f < openvas-$WMI.patch3
	patch -p1 -f < openvas-$WMI.patch3v2
	patch -p1 -f < openvas-$WMI.patch4
	patch -p1 -f < openvas-$WMI.patch5

	sed -i '/gnutls_transport_set_lowat/d' ./Samba/source/lib/tls/tls.c

	cd Samba/source/
	./autogen.sh && ./configure && make "CPP=gcc -E -ffreestanding" proto all
	make libraries

	cd $DIR
}

# Download src and create dir build
#
# Usage : prepare <version_package> <package>
function prepare() {
	ID=$1
	PK=$2

	cd $DIR

	if [ ! -f "$PK" ]; then
		wget http://wald.intevation.org/frs/download.php/$ID/$PK.tar.gz
		tar xzf $PK.tar.gz
  	fi

	cd $PK

	if [ -d "build" ]; then
		echo -e "\n\t* Removing old build/ of '$PK'"
		rm -rf build
	fi

	mkdir build

	cd ..
}

# Installation from src
#
# Usage : install <version_package> <package>
function install() {
	ID=$1
	PK=$2

	cd $DIR/$PK/build

	echo -e "\n* BUILDING $PK"
	cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/openvas -DCMAKE_BUILD_TYPE=RELEASE ..
	make
	make doc
	make install
	make rebuild_cache

	cd ../..
}

# CLeaning src
#
# Usage : clean
function clear() {
	cd $DIR
	rm *.tar.gz *.tgz
	rm -rf $NMAP $WMI $LIBRARIES $SCANNER $MANAGER $GSA $ CLI
}

# Installation of needed packages
#
# Usage : install_packages
function install_packages() {
	apt install -y \
	gcc wget make cmake build-essential autoconf pkg-config fakeroot alien nsis rsync \
	gnupg bison flex uuid-dev mingw32 \
	libglib2.0-dev libgnutls28-dev libpcap-dev libgpgme11-dev libssh-dev libldap2-dev libmicrohttpd-dev libgcrypt20-dev libpopt-dev heimdal-multidev \
	redis-server libhiredis-dev sqlite3 libsqlite3-dev \
	libxml2-dev libxslt1-dev xsltproc doxygen xmltoman texlive-latex-recommended
}

# /!\ HELP /!\
# If impossible to generate your gpg key,
# install the package "haveged" !
#
# Usage : install_gpg
function install_gpg() {
	cd /tmp
	wget http://www.openvas.org/OpenVAS_TI.asc
	gpg --homedir=/opt/openvas/etc/openvas/gnupg --gen-key
	gpg --homedir=/opt/openvas/etc/openvas/gnupg --import OpenVAS_TI.asc
	gpg --homedir=/opt/openvas/etc/openvas/gnupg --lsign-key 48DB4530
	rm OpenVAS_TI.asc
	cd $DIR
}

###

uid=`id -u`
if [ ! $uid = 0 ]; then
	echo "Execute install_openvas.sh with root !"
	exit 1
fi

###

if [ ! -d "$DIR" ]; then
	mkdir $DIR
fi
cd $DIR

###

install_packages

###

install_nmap

install_wmi $WMI

prepare $LIBID $LIBRARIES

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$DIR/$LIBRARIES/build

prepare $SMBID $SMB
install $SMBID $SMB

install $LIBID $LIBRARIES

prepare $SCANID $SCANNER
install $SCANID $SCANNER

prepare $MANID $MANAGER
install $MANID $MANAGER

prepare $GSAID $GSA
install $GSAID $GSA

prepare $CLID $CLI
install $CLID $CLI

###

echo '/opt/openvas/lib' > /etc/ld.so.conf.d/openvas
echo '/opt/openvas/lib' >> /etc/ld.so.conf
ldconfig

# Config for redis-server
sed -i "s|# unixsocket /tmp/redis.sock|unixsocket /tmp/redis.sock|" /etc/redis/redis.conf
sed -i "s|# unixsocketperm 700|unixsocketperm 755|" /etc/redis/redis.conf
systemctl restart redis-server

# Fixbug with xsltproc
sed -i '|from math import log10| a\\nSPLIT_PART_SIZE = 0' /opt/openvas/share/openvas/scap/xml_split

install_gpg()

###

echo -e "\n* Adding openvas to the enviroment PATH"
export PATH=/opt/openvas/bin:/opt/openvas/sbin:$PATH
echo -e 'export PATH=/opt/openvas/bin:/opt/openvas/sbin:$PATH' >> ~/.bashrc

echo -e "\n* Creating cert for server"
openvas-mkcert

echo -e "\n* Creating cert for client"
openvas-mkcert-client -n -i

echo -e "\n* Sync NVT in HTTP"
openvas-nvt-sync --wget

echo -e "\n* Doing the ScapData Sync"
openvas-scapdata-sync

echo -e "\n* Doing the CertData Sync"
openvas-certdata-sync

echo -e "\n* Starting the Scanner"
openvassd

echo -e "\n* Rebuilding OpenVASmd"
openvasmd --rebuild --progress

if [ ! -f "/opt/openvas/etc/openvas/pwpolicy.conf" ]; then
  touch /opt/openvas/etc/openvas/pwpolicy.conf
fi

echo -e "\n* Starting openvas manager :"
openvasmd

cd /tmp
wget http://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xml
openvas-portnames-update service-names-port-numbers.xml
rm service-names-port-numbers.xml
cd $DIR

echo -e "\n* Create admin user :"
openvasmd --create-user=admin --role=Admin
openvasmd --user=admin --new-password=admin

echo -e "\n* Starting GreenBone security assistant :"
gsad

echo -e "\n* Create config file :"
openvassd -s > /opt/openvas/etc/openvas/openvassd.conf

echo -e "\n* if any issues download and run :"
cd /tmp
wget --no-check-certificate https://svn.wald.intevation.org/svn/openvas/trunk/tools/openvas-check-setup
chmod u+x openvas-check-setup
./openvas-check-setup

###

clear

###

exit 0