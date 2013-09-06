#!/bin/sh
#
# Script de configuration d'Ansible.
#
# Auteur  : Benjamin Wendling <benjamin.wend@gmail.com>
# Version : 0.2
# Date de création : 01/09/2013
# Date de modification : 06/09/2013
# Description :	Script d'installation et de configuration d'Ansible
#
###
# Constantes initialisée par défaut
#
DIRECTORY="/home/$USER"
ANSIBLE="${DIRECTORY}/ansible"
SOURCE="${ANSIBLE}/hacking/env-setup"
MODULE="${DIRECTORY}/.ansible"
PLAYBOOKS="${MODULE}/playbooks/"
HOSTS="${MODULE}/hosts"
LOCAL="127.0.0.1"
#
#
###

# Role:
#	Affiche un message d'erreur
# Usage:
#	error
#
error() { 
	echo "ERREUR : parametres invalides !" >&2 
	echo "utilisez l'option -h pour en savoir plus" >&2 
	exit 1 
}

# Role:
#	Affiche les options disponibles du script
# Usage:
#	usage
#
usage() { 
	echo "Usage: $0 option" 
	echo "-h : afficher l'aide"
	echo "consts : Valeur des constantes"
	echo "install : installer Ansible"
	echo "config : configurer Ansible" 
}

# Role:
#	Affiche la valeur des constantes
# Usage:
#	value
#
value() {
	echo "Valeurs des paramètres :"
	echo "DIRECTORY : $DIRECTORY"
	echo "ANSIBLE : $ANSIBLE"
	echo "SOURCE : $SOURCE"
	echo "MODULE : $MODULE"
	echo "PLAYBOOKS : $PLAYBOOKS"
	echo "HOSTS : $HOSTS"
	echo "LOCAL : $LOCAL"
}

# Role:
#	Installation de modules Python, de Pip et de Git.
# Usage:
#	install
#
install() {
	echo -n "* Début de l'installation...\n"
	echo -n "* Installation des paquets : git python-pip python-jinja2 python-yaml python-paramiko\n"
	sudo apt-get install git python-pip python-jinja2 python-yaml python-paramiko
	echo -n "* Clonage du projet Ansible : github.com/ansible/ansible.git\n"
	git clone git://github.com/ansible/ansible.git $DIRECTORY
	echo -n "* Fin de l'installation\n"
}

# Role:
#	Configuration d'Ansible (fichier Hosts, variables d environnement...).
# Usage:
#	config
#
config() {
	echo -n "* Début de la configuration...\n"
	if [ -d "$DIRECTORY/ansible" ]
	then
		if [ ! -d "$PLAYBOOKS" ]
		then
			mkdir -p $PLAYBOOKS
		else
			echo -n "* Info : Le répertoire $PLAYBOOKS existe déjà !\n"
		fi
		if [ ! -s "$HOSTS" ]
		then
			echo $LOCAL > $HOSTS
		else
			echo -n "* Info : Le fichier $HOSTS existe déjà !\n"
		fi
		echo -n "\nexport ANSIBLE_HOSTS=$HOSTS" >> $SOURCE
		echo -n "\nsource ~/ansible/hacking/env-setup" >> /home/$USER/.bashrc

		# Pour finaliser l'installation, l'utilisateur doit recharger .bashrc
		echo -n "* Pour terminer la configuration : $ source ~/.bashrc\n"
	else
		echo -n "* Arrêt de la configuration : Ansible n'est pas installé !\n Usage : $0 install\n"
		exit 1
	fi
}

# Pas de paramètre 
[[ $# -lt 1 ]] && error 

case "$1" in
	consts) value
			break;;

	install) install
			 break;;

	config) config
			break;;

	-h) usage
		break;;
esac

exit 0
