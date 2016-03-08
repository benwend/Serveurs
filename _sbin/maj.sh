#############################
## 
## COMMANDE DE MISES A JOUR : SYSTEME ET APPLICATIONS
## 
#############################
##
## Name : maj.sh
## Author : benwend <benjamin.wend+git@gmail.fr>
## Date : 07/03/2016
## Version : 0.3
##
## Pour l'exécuter :
##  - Donner les droits d'exécution : $ chmod +x maj.sh
##	- Déplacer dans le dossier /bin/ : $ mv maj.sh /sbin/maj
##
#####
#!/bin/bash

apt update
echo -e "\n\tMise à jour des paquets effectués !\n"

apt full-upgrade
echo -e "\n\tRecherche de mises à jour effectués !\n"

apt-get autoremove --purge
echo -e "\n\tSuppression des paquets obsolètes effectuées !\n"

apt-get autoclean
echo -e "\n\tNettoyage du cache effectué !\n"

