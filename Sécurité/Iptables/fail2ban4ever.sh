#!/bin/sh

#
# Nom         : fail2ban4ever.sh
# Description : Extrait des logs de fail2ban les IP les plus bannies
#               pour ensuite les ajouter définitivement a iptables.
# OS          : Debian
# Requires    : iptables, fail2ban
# Licence     : GPL
# Version     : 0.0.6
# Author      : Adrien Pujol <polux@crashdump.fr>
# Web site    : http://www.crashdump.fr/
#

#-----> VARIABLES A CONFIGURER <----------------------------------------#

# Chemin vers iptables
IPT=/sbin/iptables

# Chemin vers le log de fail2ban
FAIL2BANLOG=/var/log/fail2ban.log

# Fonction date du système
DATE=`date -R`;

# Nombre de fois avant le ban définitif
NB_BEFOREBAN=3

#----- RIEN A TOUCHER APRES --------------------------------------------#

# Un peu de couleur
# 31=rouge, 32=vert, 33=jaune,34=bleu, 35=rose, 36=cyan, 37= blanc
color()
{
  #echo [$1`shift`m$*[m
  printf '\033[%sm%s\033[m\n' "$@"
}

# Helper function to get hostname(s) from variable
get_shost()
{
  # Get variable from stdin
  read hosts_ports

  CHK_HOST="$(echo "$hosts_ports" |awk -F: '{ print $1 }')"
  # IP or hostname?
  if [ -n "$(echo "$CHK_HOST" |grep -i -e '\.' -e '[a-z]')" ]; then
    echo "$CHK_HOST"
    return 0
  else
    echo "0/0"
    return 1
  fi
}

# Helper function to resolve an IP to a DNS name
# $1 = IP. stdout = DNS name
get_hostname()
{
  if [ -n "$(echo "$1" |grep '/')" ]; then
    return 1
  else
    printf "$(dig +short +tries=1 +time=1 -x "$1" 2>/dev/null |grep -v "^;;" |head -n1)"
  fi

  return 0
}

echo "+-----------------------------------------------------------------------+"
echo "|   Fail2Ban4Ever v0.0.6                                                |"
echo "|                                             <polux@crashdump.fr>      |"
echo "+-----------------------------------------------------------------------+"

# seul root peux executer ce script
if test `id -u` != "0"; then
    echo -n "`color 31 "[Erreur]"` Vous n'etes pas root, desole..."
    exit
fi

if [ ! -f "$FAIL2BANLOG" ]; then
    echo "`color 31 "[Erreur]"` Fichier $FAIL2BANLOG Introuvable"
    exit
fi

case $1 in

afficher)
    for BAD_IP in `grep "] Ban" $FAIL2BANLOG | cut -d " " -f7 | sort -u`
    do
        for NBBAD_IP in `grep -c $BAD_IP $FAIL2BANLOG`
        do
            # On vérifie quelle nest pas deja presente dans iptables
            if [ "`echo $BAD_IP`" = "`iptables-save | grep -e "$BAD_IP" | cut -d " " -f4`" ]
            then
                 echo "+-IP: `color 32 "$BAD_IP"`(`get_hostname "$BAD_IP"`): `color 32 "$NBBAD_IP -> DEJA BANNIE"`"
            # Sinon on affiche
            elif [ `echo $NBBAD_IP` -ge `echo $NB_BEFOREBAN` ]
            then
                echo "+-IP: `color 31 "$BAD_IP"`(`get_hostname "$BAD_IP"`): `color 31 "$NBBAD_IP <- TO BAN"`"
            else
                echo "| IP: `color 33 "$BAD_IP"`(`get_hostname "$BAD_IP"`): `color 33 "$NBBAD_IP"`"
            fi
        done
    done
;;

bannir)
    # Verification de la presence de la Chain dans iptables.. sinon on cree
    echo "Verification de la presence de la chaine dans iptables:"
    if [ "`iptables -L -nv --line-numbers | grep -e "Chain fail2ban4ever" | cut -d\  -f 2`" = "fail2ban4ever" ]
    then
        echo "Chaine "fail2ban4ever" trouvée dans iptables... [ `color 32 "Ok"` ]"
    else
        echo "Chaine "fail2ban4ever" non-trouvée dans iptables... [ `color 32 "Création"` ]"
        iptables -N fail2ban4ever
        iptables -I INPUT -j fail2ban4ever
    fi

    # On scanne le fichier log de fail to ban pour lister les IP déjà bannie temporairement
    for BAD_IP in `grep "] Ban" $FAIL2BANLOG | cut -d " " -f7 | sort -u`
    do
         # On compte le nombre de fois qu elle apparait !
         for NBBAD_IP in `grep -c $BAD_IP $FAIL2BANLOG`
         do
             # On vérifie quelle nest pas deja presente dans iptables
             if [ "`echo $BAD_IP`" = "`iptables-save | grep -e "$BAD_IP" | cut -d " " -f4`" ]
             then
                 echo "+-IP: `color 32 "$BAD_IP"`(`get_hostname "$BAD_IP"`): `color 32 "$NBBAD_IP -> DEJA BANNIE"`";
             # Si c est supérieur au nombre choisi et non presente dans iptables, on peut lancer le choix
             elif [ `echo $NBBAD_IP` -ge `echo $NB_BEFOREBAN` ]
             then    
                
                 echo "+-IP: `color 31 "$BAD_IP"`(`get_hostname "$BAD_IP"`): `color 31 "$NBBAD_IP -> A BANNIR"`";
                 printf "+-----> Bannir définitivement IP (OUI/non):"
                 read CHOIX
                 case $CHOIX in
                 oui)
                     echo "+-----> `color 32 "Ajoutée au /var/log/message:"` [$0] $DATE - Drop de IP : $BAD_IP(`get_hostname "$BAD_IP"`)"
                     echo "[$0] $DATE - Drop de IP : $BAD_IP(`get_hostname "$BAD_IP"`)" >> /var/log/messages;
                     echo "+-----> `color 32 "Ajoutée au regles iptables:"` iptables -I fail2ban4ever -p ALL -s $BAD_IP -j DROP"
                     iptables -I fail2ban4ever -p ALL -s $BAD_IP -j DROP -m comment --comment "generated by fail2ban4ever.sh after $NBBAD_IP attacks"
                 ;;
                 non)
                     echo "+-----> `color 31 "NON BANNIE /!\"`"
                 ;;
                 *)
                     echo "+-----> `color 32 "Ajoutée au /var/log/message:"` [$0] $DATE - Drop de IP : $BAD_IP(`get_hostname "$BAD_IP"`)"
                     echo "[$0] $DATE - Drop de IP : $BAD_IP(`get_hostname "$BAD_IP"`)" >> /var/log/messages;
                     echo "+-----> `color 32 "Ajoutée au regles iptables: "` iptables -I fail2ban4ever -p ALL -s $BAD_IP -j DROP"
                     iptables -I fail2ban4ever -p ALL -s $BAD_IP -j DROP -m comment --comment "generated by fail2ban4ever.sh after $NBBAD_IP attacks"
                 ;;
                 esac
             # Sinon on affiche le nombre de fois quelle apparais
             else
                 echo "| IP: `color 33 "$BAD_IP"`(`get_hostname "$BAD_IP"`): `color 33 "$NBBAD_IP"`";
             fi        
         done
    done 
exit
;;

purger)
    if [ "`iptables -L -nv --line-numbers | grep -e "Chain fail2ban4ever" | cut -d\  -f 2`" = "fail2ban4ever" ]
    then
        echo "Chaine "fail2ban4ever" trouvée dans iptables... [ `color 32 "Suppression"` ]"

        if [ "`iptables -L INPUT -nv --line-numbers | grep -e "fail2ban4ever" | cut -b1`" != "" ]
        then
            for FBRNB in `iptables -L fail2ban4ever -nv --line-numbers | grep -e " --" | cut -b1`
            do
                iptables -D fail2ban4ever 1
            done
            iptables -D INPUT `iptables -L INPUT -nv --line-numbers | grep -e "fail2ban4ever" | cut -b1`
            iptables -X fail2ban4ever
        else
            for FBRNB in `iptables -L fail2ban4ever -nv --line-numbers | grep -e " --" | cut -b1`
            do
                iptables -D fail2ban4ever 1
            done
            iptables -X fail2ban4ever
        fi
    else
        echo "Chaine "fail2ban4ever" non-trouvée dans iptables... [ `color 32 "Ok"` ]"
    fi
;;

*)
    echo ""
    echo "Syntaxe : $0 afficher|bannir|purger"
    exit
;;
esac

