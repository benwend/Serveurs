#!/bin/bash
################################################################################
#
# Author  : benwend <benjamin.wend+git@gmail.com>
# Version : 0.1
# Usage	  : # ./install_openvas.sh
# Summary :
#  Script for install Gogs on Debian 8.3 64bits.
#
################################################################################
#
# DOC :
#
################################################################################
#
# 17/03/2016	benwend		Initial release (v0.1)
#
################################################################################

###
# Constantes init by default
#
UID=`id -un`

# Role:
#	Affiche un message d'erreur si exécution avec droits root
# Usage:
#	root
#
root() {
	echo "ERREUR : utilisateur ou exécution avec droits ROOT !" >&2
	echo "Pour des raisons de bon fonctionnement," >&2
	echo "Ansible ne doit pas être installé avec les droits de super-administrateur !" >&2
	exit 1
}

# Role:
#	Affiche un message d'erreur s'il n'y a pas de paramètres
# Usage:
#	error
#
error() {
	echo "ERREUR : parametres invalides !" >&2
	echo "utilisez l'option -h pour en savoir plus" >&2
	exit 1
}

cd /tmp
wget https://storage.googleapis.com/golang/go$VERSION.$OS-$ARCH.tar.gz
tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
ln -s /usr/local/go/bin/* /usr/local/bin

# Create user git for gogs
sudo adduser --disabled-login --gecos 'Gogs' git
sudo su - git
cd ~
mkdir gogs
echo 'export GOPATH=$HOME/gogs' >> $HOME/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> $HOME/.bashrc
source $HOME/.bashrc

# Download and install dependencies
go get -u github.com/gogits/gogs

# Build main program
cd $GOPATH/src/github.com/gogits/gogs
go build
./gogs web