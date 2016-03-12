#!/bin/bash


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
CLID="2209"
CLI="openvas-cli-1.4.3"

FOLDER="/opt/openvas"

mkdir $FOLDER && cd $FOLDER

function install() {
	ID=$1
	PK=$2
	
	cd $FOLDER

	# Téléchargement/Décompression/Nettoyage des sources
	if [ ! -f "$PK.tar.gz" ]; then
		echo "\n* DOWNLOAD '$PK' :"
		wget http://wald.intevation.org/frs/download.php/$SMBID/$SMB.tar.gz
		echo "\n* Untar '$PK.tar.gz' :"
		tar xzf $PK.tar.gz
		echo "\n* Remove '$PK.tar.gz' :"
		rm $PK.tar.gz
  	fi

	echo "BUILD $PK :"
	cd $PK

	if [ -d "build" ]; then
		echo "\n\t* Remove old build/ of '$PK' :"
		rm -rf build
	fi

	mkdir build && cd build

	# Option -Wno-dev : Suppression des messages de debug pour les développeurs
	cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/openvas ..
	make
	make doc
	make install
	make rebuild_cache

	echo "CLEAN $PK :"
	cd .. && rm -rf build
}


echo "Installing needed packages :"
sudo apt install -y gcc wget curl make cmake build-essential pkg-config fakeroot nmap\
bison flex libgnutls28-dev libglib2.0-dev libssh-dev libpcap-dev libhiredis-dev uuid-dev libgpgme11-dev libgcrypt20-dev libldap2-dev libksba-dev libpopt-dev heimdal-multidev mingw32 libmicrohttpd-dev \
redis-server sqlite3 libsqlite3-dev \
doxygen libxml2-dev libxslt1-dev xmltoman xsltproc libxml2-dev
					  

echo "Exporting PGK_CONFIG_PATH :"
export PKG_CONFIG_PATH=/opt/openvas/lib/pkgconfig
mkdir -p $PKG_CONFIG_PATH


install $SMBID $SMB

install $LIBID $LIBRARIES

install $SCANID $SCANNER

install $MANID $MANAGER

install $GSAID $GSA

install $CLID $CLI
