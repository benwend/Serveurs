#!/bin/bash
#
################################################################################
#
# Author  : benwend <benjamin.wend+git@gmail.com>
# Date    : 14/03/2016
# Version : 0.5
#
################################################################################
# DOC :
#	http://www.openvas.org/install-source.html
#	https://github.com/ChrisFernandez/openvas_install/blob/master/install_openvas.sh
#	lab_-_openvas.pdf
################################################################################
# 11/03/2016	benwend		Initial release (v0.1)
# 12/03/2016	benwend		Create 'install' function && add page ID (v0.2)
# 12/03/2016	benwend		Test if the directory '/opt/openvas' exists (v0.3)
# 12/03/2016	benwend		Fix bugs (v0.4)
# 12/03/2016	benwend		DL CLI-1.4.2 : Bug sur Debian 8 avec 1.4.3
# 13/03/2016	benwend		Init OpenVAS (v0.5)
# 14/03/2016	benwend		Add WMI lib
# 14/03/2016	benwend		Fix many bugs
################################################################################

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
# BUG de la 1.4.3 sur debian 8 
CLID="2141"
CLI="openvas-cli-1.4.2"
WMI="wmi-1.3.14"

DIR="/opt/openvas"


# test :
# Testing return fct for continue or not
#
# Usage : test $? "my_fct"
function test() {
	if [ ! $1 = 0 ] then
		echo -e "\n\n Error in '$2' !"
		exit 1
	fi
}

# install_wmi :
# installation of lib wmi
#
# Usage : install_wmi
function install_wmi() {
	cd $DIR

	if [ ! -f "$WMI.tar.gz" ]; then
		wget http://openvas.org/download/wmi/$WMI.tar.bz2
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

	patch -p1 -R < openvas-$WMI.patch
	patch -p1 -R < openvas-$WMI.patch2
	patch -p1 -R < openvas-$WMI.patch3
	patch -p1 -R < openvas-$WMI.patch3v2
	patch -p1 -R < openvas-$WMI.patch4
	patch -p1 -R < openvas-$WMI.patch5

	sed -i '/gnutls_transport_set_lowat/d' ./Samba/source/lib/tls/tls.c

	cd Samba/source/
	./autogen.sh && ./configure && make "CPP=gcc -E -ffreestanding" proto all
	make libraries

	cd $DIR
}

# prepare :
# Download src and create dir build
#
# Usage : prepare <version_package> <package>
function prepare() {
	ID=$1
	PK=$2

	cd $DIR

	if [ ! -f "$PK.tar.gz" ]; then
		echo -e "\n* DOWNLOADING '$PK'"
		wget http://wald.intevation.org/frs/download.php/$ID/$PK.tar.gz
		echo -e "\n* Untaring '$PK.tar.gz'"
		tar xzf $PK.tar.gz
		echo -e "\n* Removing '$PK.tar.gz'"
		rm $PK.tar.gz
  	fi

	echo -e "\n* PREBUILDING $PK"
	cd $PK

	if [ -d "build" ]; then
		echo -e "\n\t* Removing old build/ of '$PK'"
		rm -rf build
	fi

	mkdir build

	cd ..
}

# install :
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

# template_install :
# prepare() and install()
#
# Usage : template_install <version_package> <package>
function template_install() {
	ID=$1
	PK=$2

	cd $DIR

	# Téléchargement/Décompression/Nettoyage des sources
	if [ ! -f "$PK.tar.gz" ]; then
		echo -e "\n* DOWNLOADING '$PK'"
		wget http://wald.intevation.org/frs/download.php/$ID/$PK.tar.gz
		echo -e "\n* Untaring '$PK.tar.gz'"
		tar xzf $PK.tar.gz
		echo -e "\n* Removing '$PK.tar.gz'"
		rm $PK.tar.gz
  	fi

	echo -e "\n* BUILDING $PK"
	cd $PK

	if [ -d "build" ]; then
		echo -e "\n\t* Removing old build/ of '$PK'"
		rm -rf build
	fi

	mkdir build && cd build

	# Option -Wno-dev : Suppression des messages de debug pour les développeurs
	cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/openvas -DCMAKE_BUILD_TYPE=RELEASE ..
	make
	make doc
	make install
	make rebuild_cache

	cd ../..
}

###

if [ ! -d "$DIR" ]; then
	mkdir $DIR
fi
cd $DIR

###

echo -e "\n* Installing needed packages :"
sudo apt install -y \
gcc wget make cmake build-essential autoconf pkg-config fakeroot alien nsis rsync \
bison flex uuid-dev mingw32 \
libglib2.0-dev libgnutls28-dev libpcap-dev libgpgme11-dev libssh-dev libldap2-dev libmicrohttpd-dev libgcrypt20-dev libpopt-dev heimdal-multidev \
redis-server libhiredis-dev sqlite3 libsqlite3-dev \
libxml2-dev libxslt1-dev xsltproc doxygen xmltoman texlive-latex-base

###

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

wget http://nmap.org/dist/nmap-5.51.6.tgz
tar xvf nmap-5.51.6.tgz
cd nmap-5.51.6
./configure
make
make install

###

echo '/opt/openvas/lib' > /etc/ld.so.conf.d/openvas
echo '/opt/openvas/lib' >> /etc/ld.so.conf
sudo ldconfig

echo -e "\n* Adding openvas to the enviroment PATH :"
export PATH=/opt/openvas/bin:/opt/openvas/sbin:$PATH
echo -e 'export PATH=/opt/openvas/bin:/opt/openvas/sbin:$PATH' >> ~/.bashrc

echo -e "\n* Creating cert for server :"
openvas-mkcert

echo -e "\n* Creating cert for client :"
openvas-mkcert-client -n -i

echo -e "\n* Sync NVT :"
# Add option --wget if rsync is blocked by the FW
openvas-nvt-sync

echo -e "\n* Doing the ScapData Sync :"
openvas-scapdata-sync && sleep 1800

echo -e "\n* Doing the CertData Sync :"
openvas-certdata-sync && sleep 120

echo -e "\n* Starting the scanner :"
openvassd

echo -e "\n* Rebuilding OpenVASmd :"
openvasmd --rebuild

if [ ! -f "/opt/openvas/etc/openvas/pwpolicy.conf" ]; then
  echo -e "\n* Creating password policy file, read the doc and edit it as you need"
  sudo touch /opt/openvas/etc/openvas/pwpolicy.conf
fi

echo -e "\n* Starting openvas manager :"
openvasmd

cd /tmp
wget http://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xml
openvas-portnames-update service-names-port-numbers.xml
rm service-names-port-numbers.xml
cd $DIR

echo -e "\n* Create admin user :"
sopenvasmd --create-user=admin --role=Admin
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

exit 0