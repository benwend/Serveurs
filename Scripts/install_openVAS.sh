#!/bin/bash
#
################################################################################
#
# Author  : benwend <benjamin.wend+git@gmail.com>
# Date    : 13/03/2016
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
# 13/03/2016	benwend		Init OpenVAS (In going -- v0.5)
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

function install() {
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
	cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/openvas ..
	make
	make doc
	make install
	make rebuild_cache

	echo -e "\n* CLEANNING $PK"
	cd .. && rm -rf build
}


if [ ! -d "$DIR" ]; then
	sudo 
else
	cd $DIR
fi

echo -e "\n* Installing needed packages :"
sudo apt install -y \
gcc wget make cmake build-essential autoconf pkg-config fakeroot alien nsis \
bison flex uuid-dev mingw32 \
libglib2.0-dev libgnutls28-dev libpcap-dev libgpgme11-dev libssh-dev libldap2-dev libmicrohttpd-dev libgcrypt20-dev libpopt-dev heimdal-multidev \
redis-server libhiredis-dev sqlite3 libsqlite3-dev \
libxml2-dev libxslt1-dev xsltproc doxygen xmltoman

echo -e "\n* Exporting PGK_CONFIG_PATH :"
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


echo -e "\n* Adding openvas to the enviroment PATH"
export PATH=/opt/openvas/bin:/opt/openvas/sbin:$PATH
sudo sh -c "echo 'export PATH=/opt/openvas/bin:/opt/openvas/sbin:$PATH' >> /etc/bash.bashrc" 

sudo sh -c "echo '/opt/openvas/lib' > /etc/ld.so.conf.d/openvas"
sudo sh -c "echo '/opt/openvas/lib' >> /etc/ld.so.conf"
sudo ldconfig


#configure

echo -e "\n* CONFIGURE"

echo -e "\n* Creating cert for server :"
sudo /opt/openvas/sbin/openvas-mkcert

echo -e "\n* Sync NVT :"
sudo -b env  PATH="/opt/openvas/bin:/opt/openvas/sbin:$PATH" /opt/openvas/sbin/openvas-nvt-sync

echo -e "\n* Creating cert for client :"
sudo -b env  PATH="/opt/openvas/bin:/opt/openvas/sbin:$PATH" /opt/openvas/sbin/openvas-mkcert-client -n -i

echo -e "\n* Starting the scanner"
sudo -b env  PATH="/opt/openvas/bin:/opt/openvas/sbin:$PATH" /opt/openvas/sbin/openvassd

echo -e "\n* Rebuilding OpenVASmd"
sudo /opt/openvas/sbin/openvasmd --rebuild

echo -e "\n* Doing the ScapData Sync"
sudo -b env  PATH="/opt/openvas/bin:/opt/openvas/sbin:$PATH" /opt/openvas/sbin/openvas-scapdata-sync

echo -e "\n* Doing the CertData sync"
sudo -b env  PATH="/opt/openvas/bin:/opt/openvas/sbin:$PATH" /opt/openvas/sbin/openvas-certdata-sync

if [ ! -f "/opt/openvas/etc/openvas/pwpolicy.conf" ]; then
  echo -e "\n* Creating password policy file, read the doc and edit it as you need"
  sudo touch /opt/openvas/etc/openvas/pwpolicy.conf
fi

echo -e "\n* Starting openvas manager"
sudo -b env  PATH="/opt/openvas/bin:/opt/openvas/sbin:$PATH" /opt/openvas/sbin/openvasmd

echo -e "\n* Starting GreenBone security assistant"
sudo -b env  PATH="/opt/openvas/bin:/opt/openvas/sbin:$PATH" /opt/openvas/sbin/gsad

echo -e "\n* Create config file"
sudo -b env  PATH="/opt/openvas/bin:/opt/openvas/sbin:$PATH" openvassd -s > /opt/openvas/etc/openvas/openvassd.conf

echo -e "\n* Create your first user :"
echo -e "\n* openvasmd --first-user=myuser"

echo -e "\n* if any issues download and run :"
echo -e "\n* wget --no-check-certificate https://svn.wald.intevation.org/svn/openvas/trunk/tools/openvas-check-setup"
