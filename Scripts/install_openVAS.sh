#!/bin/bash
#
################################################################################
#
# Author  : benwend <benjamin.wend+git@gmail.com>
# Date    : 12/03/2016
# Version : 0.4
#
################################################################################
# DOC :
#	http://www.openvas.org/install-source.html
#	https://github.com/ChrisFernandez/openvas_install/blob/master/install_openvas.sh
################################################################################
# 11/03/2016	benwend		Initial release (v0.1)
# 12/03/2016	benwend		Create 'install' function && add page ID (v0.2)
# 12/03/2016	benwend		Test if the directory '/opt/openvas' exists (v0.3)
# 12/03/2016	benwend		Fix bugs (v0.4)
# 12/03/2016	benwend		DL CLI-1.4.2 : Bug sur Debian 8 avec 1.4.3
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

DIR="/opt/openvas"

if [ ! -d "$DIR" ]; then
	echo -e "No directory '/opt/openvas' !"
	echo -e "Exec the cmd \"sudo mkdir $DIR && sudo chown <USERNAME>:<USERNAME> $DIR\""
	echo -e "Goodbye"
	exit 1
else
	cd $DIR
fi

function install() {
	ID=$1
	PK=$2

	cd $DIR

	# Téléchargement/Décompression/Nettoyage des sources
	if [ ! -f "$PK.tar.gz" ]; then
		echo -e "\n* DOWNLOAD '$PK' :"
		wget http://wald.intevation.org/frs/download.php/$ID/$PK.tar.gz
		echo -e "\n* Untar '$PK.tar.gz' :"
		tar xzf $PK.tar.gz
		echo -e "\n* Remove '$PK.tar.gz' :"
		rm $PK.tar.gz
  	fi

	echo -e "BUILD $PK :"
	cd $PK

	if [ -d "build" ]; then
		echo -e "\n\t* Remove old build/ of '$PK' :"
		rm -rf build
	fi

	mkdir build && cd build

	# Option -Wno-dev : Suppression des messages de debug pour les développeurs
	cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/openvas ..
	make
	make doc
	make install
	make rebuild_cache

	echo -e "CLEAN $PK :"
	cd .. && rm -rf build
}


echo -e "Installing needed packages :"
sudo apt install -y gcc wget curl make cmake build-essential pkg-config fakeroot nmap \
bison flex libgnutls28-dev libglib2.0-dev libssh-dev libpcap-dev libhiredis-dev uuid-dev libgpgme11-dev libgcrypt20-dev libldap2-dev libksba-dev libpopt-dev heimdal-multidev mingw32 libmicrohttpd-dev \
redis-server sqlite3 libsqlite3-dev \
doxygen libxml2-dev libxslt1-dev xmltoman xsltproc libxml2-dev

echo -e "Exporting PGK_CONFIG_PATH :"
export PKG_CONFIG_PATH=/opt/openvas/lib/pkgconfig
if [ ! -d "$PKG_CONFIG_PATH" ]; then
	mkdir -p $PKG_CONFIG_PATH
fi

install $SMBID $SMB

install $LIBID $LIBRARIES

install $SCANID $SCANNER

install $MANID $MANAGER

install $GSAID $GSA

install $CLID $CLI
