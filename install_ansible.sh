#!/bin/sh
#
# Script de configuration d'Ansible.
#
# Auteur  : Benjamin Wendling <benjamin.wend@gmail.com>
# Version : 0.4
# Date de création : 01/09/2013
# Date de modification : 07/09/2013
# Description :	Script d'installation et de configuration d'Ansible,
#	et permet désormais de supprimer Ansible. Le script gère aussi
#	la configuration de Git avec ajout de la clé SSH dans l'agent.
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
GITNAME="benwend"
GITEMAIL="benjamin.wend+git@gmail.com"
GITKEY="$DIRECTORY/.ssh/github.ppk"
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
	echo " -h : afficher l'aide"
	echo " config  : Configurer Ansible"
	echo " consts  : Valeurs des constantes"
	echo " install : Installer Ansible"
	echo " remove  : Supprimer Ansible"
}

# Role:
#	Affiche la valeur des constantes
# Usage:
#	value
#
value() {
	echo "Valeurs des paramètres, à modifier directement dans le script :"
	echo "DIRECTORY = $DIRECTORY"
	echo "ANSIBLE 	= $ANSIBLE"
	echo "SOURCE 	= $SOURCE"
	echo "MODULE 	= $MODULE"
	echo "PLAYBOOKS = $PLAYBOOKS"
	echo "HOSTS 	= $HOSTS"
	echo "LOCAL 	= $LOCAL"
	echo "GITNAME 	= $GITNAME"
	echo "GITEMAIL 	= $GITEMAIL"
	echo "GITKEY 	= $GITKEY"
}

# Role:
#	Configuration d'Ansible (fichier Hosts, variables d environnement...).
# Usage:
#	config
#
config() {
	echo "* Début de la configuration :"
	if [ -d "$ANSIBLE" ]
	then
		if [ -d "$MODULE" ]
		then
			echo "** Clonage de la branche Ansible : github.com/ansible/ansible.git..."
			git clone -o .ansible -b ansible git@github.com:benwend/serveurs.git $MODULE

			echo "** Ajout des alias et chemins Ansible..."
			sed -i \
			"/# Print out values unless -q is set/i \
			# ALIAS\n\
			# Chemin du fichier HOSTS\n\
			export ANSIBLE_HOSTS=$HOSTS\n" $SOURCE

			sed -i \
			"/echo \"MANPATH=$MANPATH\"/a \
			echo \"ANSIBLE_HOSTS=$ANSIBLE_HOSTS\"/" $SOURCE

			echo -e \
			"# Chargement de l'environnement Ansible au démarrage de la session\
			source ~/ansible/hacking/env-setup" >> $DIRECTORY/.bashrc

			# Pour finaliser l'installation, l'utilisateur doit recharger .bashrc
			echo "* Pour terminer la configuration : $ source ~/.bashrc."
		else
			echo "* ERREUR : $MODULE a déjà été cloné !"
			exit 1
		fi
	else
		echo "* ERREUR : $ANSIBLE n'est pas installé !"
		echo "Usage : $0 install"
		exit 1
	fi
}

# Role:
#	Configuration global de Git
# Usage:
#	gitconfig
#
gitconf() {
	echo "** Configuration globale de git en cours..."
	git config --global color.diff auto
	git config --global color.status auto
	git config --global color.branch auto
	git config --global user.name $GITNAME
	git config --global user.email $GITEMAIL

	echo "** Ajout de la clé privée dans l'agent..."
	if [ -f "$GITKEY" ]
		then
		ssh-add $GITKEY
	else
		echo "** INFO : $GITKEY n'existe pas. Veuillez l'ajouter manuellement !"
	fi
}

# Role:
#	Installation de modules Python, de Pip et de Git.
# Usage:
#	install
#
install() {
	echo "* Début de l'installation :"
	echo "** Installation des paquets : git python-pip python-jinja2 python-yaml python-paramiko..."
	sudo apt-get install git python-pip python-jinja2 python-yaml python-paramiko
	gitconfig
	echo "** Clonage du projet Ansible : github.com/ansible/ansible.git..."
	git clone git://github.com/ansible/ansible.git $DIRECTORY
	echo "* Fin de l'installation."
}

# Role:
#	Suppression d'Ansible (fichier Hosts, variables d environnement, sources...).
# Usage:
#	remove
#
remove() {
	echo "* Début de la suppression d'Ansible :"

	echo "** Suppression des sources..."
	if [ -d "$ANSIBLE"]
		then
		rm -r $ANSIBLE
	else
		echo "** INFO : $ANSIBLE déjà supprimé !"
	fi
	
	if [ -d "$MODULE"]
		then
		rm -r $MODULE
	else
		echo "** INFO : $MODULE déjà supprimé !"
	fi

	echo "** Suppression des alias et chemins..."
	sed -i "/# Chargement de l'environnement Ansible au démarrage de la session/d" $DIRECTORY/.bashrc
	sed -i "/source ~/ansible/hacking/env-setup/d" $DIRECTORY/.bashrc

	echo "** Suppression des dépendances..."
	sudo apt-get autoremove --purge python-pip python-jinja2 python-yaml python-paramiko
	sudo apt-get autoclean

	echo "* Fin de la suppression."
}

# Si pas de paramètres
[[ $# -lt 1 ]] && error
# Sinon
case "$1" in
	-h)
		usage
		break;;
	config)
		config
		break;;
	consts)
		value
		break;;
	install)
		install
		break;;
	remove)
		remove
		break;;
	*)
		error ;;
esac
exit 0
