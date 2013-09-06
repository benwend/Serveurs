#!/bin/sh
#
# Script de configuration d'Ansible.
#
# Auteur  : Benjamin Wendling <benjamin.wend@gmail.com>
# Version : 0.1
# Date de création : 01/09/2013
# Date de modification : 01/09/2013
# Description :	Script d'installation et de configuration d'Ansible
#
###
# Variables initialisée par défaut
#
DIRECTORY="/home/$USER"
ANSIBLE="${DIRECTORY}/ansible"
MODULE="${DIRECTORY}/.ansible"
HOSTS="${MODULE}/hosts"
PLAYBOOKS="${MODULE}/playbooks/"
LOCAL="127.0.0.1"
SOURCE="${ANSIBLE}/hacking/env-setup"
#
#
###

#Role:
#	Installation de modules Python, de Pip et de Git.
#Usage:
#	ansible_install
#
ansible_install()
{
sudo apt-get install git python-pip python-jinja2 python-yaml python-paramiko
git clone git://github.com/ansible/ansible.git $DIRECTORY
}

#Role:
#	Configuration d'Ansible (fichier Hosts, variables d environnement...).
#Usage:
#	ansible_configure
#
ansible_configure()
{

if [ -d "$DIRECTORY/ansible" ]
then
	if [ ! -d "$PLAYBOOKS" ]
	then
		mkdir -p $PLAYBOOKS
	else
		echo -n "Erreur : Le répertoire $PLAYBOOKS existe déjà !\n"
	fi
	if [ ! -s "$HOSTS" ]
	then
		echo $LOCAL > $HOSTS
	else
		echo -n "Erreur : Le fichier $HOSTS existe déjà !\n"
	fi
	echo -n "\nexport ANSIBLE_HOSTS=$HOSTS" >> $SOURCE
	echo -n "\nsource ~/ansible/hacking/env-setup" >> /home/$USER/.bashrc
else
	echo -n "Ansible n'est pas installé. Usage : $0 install\n"
fi
}

case "$1" in
install)
	echo -n "install_ansible.sh : Installation en cours...\n"
	ansible_install
	echo -n "...\n"
	echo -n "Installation terminée.\n"
	;;
configure)
	echo -n "install_ansible.sh : Configuration en cours.\n"
	ansible_configure
	echo -n "...\n"
	echo -n "Pour terminer la configuration : $ source ~/.bashrc\n"
	;;
*)
	echo -n "Usage: $0 {install|configure}\n"
	exit 1
	;;
esac
exit 0
