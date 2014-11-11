#############################
## 
## COMMANDE DE MISES A JOUR : SYSTEME ET APPLICATIONS
## 
#############################
##
## Name : maj.sh
## Author : benwend <ben_wend@hotmail.fr>
## Date : 11/11/2014
## Version : 0.2
##
## Pour l'exécuter :
##  - Donner les droits d'exécution : $ chmod +x maj.sh
##	- Déplacer dans le dossier /bin/ : $ mv maj.sh /bin/maj
##
#####
#!/bin/bash

sudo apt-get update
echo -e "\n\tMise à jour des paquets effectués !\n"

sudo apt-get dist-upgrade
echo -e "\n\tRecherche de mises à jour effectués !\n"

sudo apt-get autoremove --purge
echo -e "\n\tSuppression des paquets obsolètes effectuées !\n"

sudo apt-get autoclean
echo -e "\n\tNettoyage du cache effectué !\n"
