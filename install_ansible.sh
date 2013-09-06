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
	echo "Usage: $0 [option]"
	echo "Liste des options :"
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
	echo "* Début de l'installation..."
	echo "* Installation des paquets : git python-pip python-jinja2 python-yaml python-paramiko"
	sudo apt-get install git python-pip python-jinja2 python-yaml python-paramiko
	echo "* Clonage du projet Ansible : github.com/ansible/ansible.git"
	git clone git://github.com/ansible/ansible.git $DIRECTORY
	echo "* Fin de l'installation"
}

# Role:
#	Configuration d'Ansible (fichier Hosts, variables d environnement...).
# Usage:
#	config
#
config() {
	echo "* Début de la configuration..."
	if [ -d "$ANSIBLE" ]
	then
		if [ -d "$MODULE" ]
		then
			echo "* Clonage du projet Ansible : github.com/ansible/ansible.git"
			git clone -o .ansible -b ansible git@github.com:benwend/serveurs.git $MODULE
			ssh-add $DIRECTORY/.ssh/github.ppk
			
			echo "# Chemin du fichier hosts" >> $SOURCE
			echo "export ANSIBLE_HOSTS=$HOSTS" >> $SOURCE

			echo "# Chargement de l'environnement Ansible au démarrage de la session" >> /home/$USER/.bashrc
			echo "source ~/ansible/hacking/env-setup" >> /home/$USER/.bashrc

			# Pour finaliser l'installation, l'utilisateur doit recharger .bashrc
			echo "* Pour terminer la configuration : $ source ~/.bashrc"
		else
			echo "* Arrêt de la configuration : .ansible a déjà été cloné !"
			exit 1
		fi
	else
		echo "* Arrêt de la configuration : Ansible n'est pas installé !"
		echo "Usage : $0 install"
		exit 1
	fi
}

gitconf() {
	echo "* Configuration de git en cours..."
	git config --global color.diff auto
	git config --global color.status auto
	git config --global color.branch auto
	git config --global user.name "benwend"
	git config --global user.email benjamin.wend+git@gmail.com
}

# Pas de paramètre
[[ $# -lt 1 ]] && error

case "$1" in
	consts)
		value
		break;;

	install)
		install
		break;;

	config)
		config
		break;;

	-h)
		usage
		break;;

	*) error ;;
esac

exit 0
