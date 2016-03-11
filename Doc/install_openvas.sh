#!/bin/bash

SMB="openvas-smb-1.0.1"
LIBRARIES="openvas-libraries-8.0.7"
SCANNER="openvas-scanner-5.0.5"
MANAGER="openvas-manager-6.0.8"
CLI="openvas-cli-1.4.3"
GSA="greenbone-security-assistant-6.0.10"

FOLDER="/opt/openvas"

mkdir $FOLDER && cd $FOLDER

echo "Download :"
wget wget http://wald.intevation.org/frs/download.php/1975/$SMB.tar.gz
wget http://wald.intevation.org/frs/download.php/2291/$LIBRARIES.tar.gz
wget http://wald.intevation.org/frs/download.php/2266/$SCANNER.tar.gz
wget http://wald.intevation.org/frs/download.php/2295/$MANAGER.tar.gz
wget http://wald.intevation.org/frs/download.php/2209/$CLI.tar.gz
wget http://wald.intevation.org/frs/download.php/2299/$GSA.tar.gz

echo "Build :"
tar xzf $SMB.tar.gz
tar xzf $LIBRARIES.tar.gz
tar xzf $SCANNER.tar.gz
tar xzf $MANAGER.tar.gz
tar xzf $CLI.tar.gz
tar xzf $GSA.tar.gz

rm *.tar.gz

echo "Installing needed packages"
sudo apt install -y gcc bison flex cmake pkg-config libgnutls28-dev libglib2.0-dev libssh-dev libpcap-dev libhiredis-dev uuid-dev libgpgme11-dev libgcrypt20-dev doxygen libldap2-dev libksba-dev libpopt-dev heimdal-multidev mingw32 redis-server libsqlite3-dev xmltoman xsltproc libmicrohttpd-dev libxslt1-dev

echo "exporting PGK_CONFIG_PATH :"
export PKG_CONFIG_PATH=/opt/openvas/lib/pkgconfig
mkdir -p $PKG_CONFIG_PATH

echo "INSTALLATION DE $SMB :"
cd $FOLDER/$SMB
mkdir build
cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/openvas ..
make
sudo make install
make rebuild_cache
cd .. && rm -rf build

echo "INSTALLATION DE $LIBRARIES :"
cd $FOLDER/$LIBRARIES
mkdir build
cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/openvas ..
make
make doc
sudo make install
make rebuild_cache
cd .. && rm -rf build

echo "INSTALLATION DE $SCANNER :"
cd $FOLDER/$SCANNER
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/openvas ..
make
make doc
sudo make install
make rebuild_cache
cd .. && rm -rf build

echo "INSTALLATION DE $MANAGER :"
cd $FOLDER/$MANAGER
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/openvas ..
make
make doc
sudo make install
make rebuild_cache
cd .. && rm -rf build

echo "INSTALLATION DE $GSA :"
cd $FOLDER/$GSA
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/openvas ..
make
make doc
sudo make install
make rebuild_cache
cd .. && rm -rf build

echo "INSTALLATION DE $CLI :"
cd $FOLDER/$CLI
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/openvas ..
make
make doc
sudo make install
make rebuild_cache
cd .. && rm -rf build

