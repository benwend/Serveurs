Serveurs
========

Scripts pour mes serveurs personnels


Ansible
-------

Playbooks Ansible [AnsibleWorks](http://ansibleworks.com)

Ansible is a radically simple configuration-management, deployment, task-execution, and multinode orchestration framework.

Read the documentation and more at http://ansibleworks.com/

Many users run straight from the development branch (it's generally fine to do so), but you might also wish to consume a release.
You can find instructions [here](http://ansibleworks.com/docs/intro_getting_started.html) for a variety of platforms.
If you want a tarball of the last release, go to http://ansibleworks.com/releases/ and you can also install with pip.

Context
=======

Cette branche contient l'ensemble de mes playbooks afin de maintenir facile ces scripts mais aussi de faire évoluer proporement mes serveurs et facileter le redéploiement en cas de duplication ou de restauration.
Mais aussi de partager mes idées et/ou les faire améliorer au sein de la communauté du libre que ce soit d'un point purement technique ou même d'un point de vue théorique.

Branch Info
===========

	* Actuellement -> branche de développement/production
	* Playbooks uniquement

Execution
=========

	Commande pour lancer une commande (-a) sous un utilisateur (-u) avec droit sudo (-K) sur le serveur voulu (host) :
	* ansible host -a "cmd" -u username -K

	Lancement d'une commande (-a) avec un username (-u) via un user(-U) qui a des droits sudo (-K) :
	* ansible host -a "cmd" -u username -K -U otherUser

	Exécution d'un playbook :
	* ansible-playbook -i host playbook.yml

Author
======

Benjamin Wendling -- ben_wend@hotmail.fr
