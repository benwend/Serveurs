### BEGIN INIT INFO
# Provides:          firewall
# Required-Start:    $network
# Required-Stop:     $network
# Default-Start:     S 2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: The Firewall rules
# Description:       Firewall my ass
### END INIT INFO

#-----------------------------------------------------------------------#
#                                                                       #
# Description : Firewall Config                                         #
# OS          : Debian                                                  #
# Requires    : iptables + module ip_conntrack                          #
# Licence     : GPL                                                     #
# Version     : 0.1.7-3                                                 #
# Author      : Adrien Pujol <adrien.pujol@crashdump.fr>                #
# Web site    : http://www.crashdump.fr/                                #
#                                                                       #
#-----------------------------------------------------------------------#

test -f /sbin/iptables || exit 0

. /lib/lsb/init-functions

# Un peu de couleurs ?
#31=rouge, 32=vert, 33=jaune,34=bleu, 35=rose, 36=cyan, 37= blanc
color()
{
  #echo [$1`shift`m$*[m
  printf '\033[%sm%s\033[m\n' "$@"
}

#-----> VARIABLES A CONFIGURER <----------------------------------------#

IPTABLES=/sbin/iptables
IF_EXT=eth0
LOGFLAGS="LOG --log-tcp-options --log-tcp-sequence --log-ip-options --log-level warning --log-prefix"

modprobe ip_conntrack

#-----> START/STOP <----------------------------------------------------#

case "$1" in
    start)
	log_begin_msg "Starting iptables firewall rules..."
	######################################################################
	
	#----- Initialisation --------------------------------------------------#

	echo ">Shutting down Fail2Ban"
	/etc/init.d/fail2ban stop

	echo ">Setting firewall rules..."

	## Vider les tables actuelles
	${IPTABLES} -t filter -F
	${IPTABLES} -t filter -X
	${IPTABLES} -t mangle -F
	${IPTABLES} -t mangle -X
	${IPTABLES} -t nat -F
	${IPTABLES} -t nat -X
	${IPTABLES} -F
	${IPTABLES} -X
	${IPTABLES} -Z
	echo "- Vidage : [`color 32 "OK"`]"

	#----- VPN -------------------------------------------------------------#

	echo 0 > /proc/sys/net/ipv4/ip_forward 

	#----- Regles par defaut -----------------------------------------------#

	## ignore_echo_broadcasts, TCP Syncookies, ip_forward
	echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
	echo "1" > /proc/sys/net/ipv4/tcp_syncookies
	echo "1" > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
	echo "1" > /proc/sys/net/ipv4/conf/all/accept_redirects
	echo "1" > /proc/sys/net/ipv4/conf/all/log_martians
	echo "- Ignorer les echo braodcast, TCP Syncookies et IP Forward : [`color 32 "OK"`]"

	#Reduce DoS'ing ability by reducing timeouts
	echo "30" > /proc/sys/net/ipv4/tcp_fin_timeout
	echo "1800" > /proc/sys/net/ipv4/tcp_keepalive_time
	echo "1" > /proc/sys/net/ipv4/tcp_window_scaling
	echo "0" > /proc/sys/net/ipv4/tcp_sack
	echo "1280" > /proc/sys/net/ipv4/tcp_max_syn_backlog

	## Police par defaut
	${IPTABLES} -P INPUT DROP
	${IPTABLES} -P OUTPUT DROP
	${IPTABLES} -P FORWARD DROP
	echo "- Police par defaut, DROP : [`color 32 "OK"`]"

	## Loopback accepte
	${IPTABLES} -A FORWARD -i lo -o lo -j ACCEPT
	${IPTABLES} -A INPUT -i lo -j ACCEPT
	${IPTABLES} -A OUTPUT -o lo -j ACCEPT
	echo "- Accepter les loopbacks : [`color 32 "OK"`]"

	#----- Creation chaines  ------------------------------------------------#

	## Creation des chaines
	${IPTABLES} -N SERVICES
	${IPTABLES} -N THISISPORN
	${IPTABLES} -N SECURITY
	echo "- Creation des chaines : [`color 32 "OK"`]"

	#----- Security ---------------------------------------------------------#

	# Monitoring server, specials rules:
	${IPTABLES} -I SECURITY -p tcp -m tcp --tcp-flags RST RST -s 95.130.8.5 -j ACCEPT                                                  -m comment --comment "Monitoring server"
	${IPTABLES} -I SECURITY -p icmp --icmp-type echo-request -s 95.130.8.5 -j ACCEPT                                                   -m comment --comment "Monitoring server"

	# Anyone who tried to portscan us is locked out for an entire day.
	${IPTABLES} -A SECURITY -m recent --name portscan --rcheck --seconds 86400 -j DROP                                                 -m comment --comment "Portscan"
	# Once the day has passed, remove them from the portscan list
	${IPTABLES} -A SECURITY -m recent --name portscan --remove                                                                         -m comment --comment "Portscan"
	# These rules add scanners to the portscan list, and log the attempt.
	${IPTABLES} -A SECURITY -p tcp -m tcp --dport 139 -m recent --name portscan --set -j ${LOGFLAGS} "[iptables] [:portscan:]"         -m comment --comment "Portscan"
	${IPTABLES} -A SECURITY -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP                                          -m comment --comment "Portscan"
	${IPTABLES} -A SECURITY -p tcp -m tcp --dport 5353 -m recent --name portscan --set -j ${LOGFLAGS} "[iptables] [:portscan:]"        -m comment --comment "Portscan"
	${IPTABLES} -A SECURITY -p tcp -m tcp --dport 5353 -m recent --name portscan --set -j DROP                                         -m comment --comment "Portscan"
	echo "- Portscan (Connect. on port 139 banned for a day) : [`color 32 "OK"`]"

	## No NULL Packet
	${IPTABLES} -A SECURITY -p tcp --tcp-flags ALL NONE -m limit --limit 5/m --limit-burst 7 -j ${LOGFLAGS} "[iptables] [:nullpackets:]" -m comment --comment "Null packets"
	${IPTABLES} -A SECURITY -p tcp --tcp-flags ALL NONE -j DROP                                                                        -m comment --comment "Null packets"
	echo "- Protection NULL Packets : [`color 32 "OK"`]"

	## No SYN Flood 
	${IPTABLES} -A SECURITY -p tcp --syn -m limit --limit 2/second --limit-burst 5 --dport 80 -j ACCEPT                                -m comment --comment "Syn flood"
	${IPTABLES} -A SECURITY -p tcp --syn -m limit --limit 5/second --limit-burst 10 -j ACCEPT                                          -m comment --comment "Syn flood"
	${IPTABLES} -A SECURITY -p tcp --syn -m limit --limit 20/m --limit-burst 10 -j ${LOGFLAGS} "[iptables] [:synflood:]"               -m comment --comment "Syn flood"
	${IPTABLES} -A SECURITY -p tcp --syn -j DROP                                                                                       -m comment --comment "Syn flood"
	echo "- Protection SYN Flood : [`color 32 "OK"`]"

	## No XMAS 
	${IPTABLES} -A SECURITY -p tcp --tcp-flags SYN,FIN SYN,FIN -m limit --limit 5/m --limit-burst 7 -j ${LOGFLAGS} "[iptables] [:xmaspackets:]" -m comment --comment "Xmas packet"
	${IPTABLES} -A SECURITY -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP                                                                 -m comment --comment "Xmas packet"
	echo "- Protection XMAS : [`color 32 "OK"`]"

	## No FIN packet scans
	${IPTABLES} -A SECURITY -p tcp --tcp-flags FIN,ACK FIN -m limit --limit 5/m --limit-burst 7 -j ${LOGFLAGS} "[iptables] [:finpacketsscan:]" -m comment --comment "Fin packet"
	${IPTABLES} -A SECURITY -p tcp --tcp-flags FIN,ACK FIN -j DROP                                                                     -m comment --comment "Fin packet"
	${IPTABLES} -A SECURITY -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP                                                         -m comment --comment "Fin packet"
	echo "- Protection FIN packet scans : [`color 32 "OK"`]"

	## No slowloris
	#${IPTABLES} -A SECURITY -p tcp --dport 80 -m connlimit --connlimit-above 25 --connlimit-mask 32 -j ${LOGFLAGS} "[iptables] [:slowloris:]" -m comment --comment "Slowloris"
	#${IPTABLES} -A SECURITY -p tcp --dport 80 -m connlimit --connlimit-above 25 --connlimit-mask 32 -j DROP                            -m comment --comment "Slowloris"
	echo "- Protection HTTP Slowloris : [`color 32 "DISABLED - NGINX"`]"

	# Drop excessive RST packets to avoid SMURF attacks, by given the
	# next real data packet in the sequence a better chance to arrive first.
	${IPTABLES} -A SECURITY -p tcp -m tcp --tcp-flags RST RST -m limit --limit 3/second --limit-burst 5 -j ${LOGFLAGS} "[iptables] [:smurfddos:]" -m comment --comment "Smurf attck"
	${IPTABLES} -A SECURITY -p tcp -m tcp --tcp-flags RST RST -m limit --limit 3/second --limit-burst 5 -j ACCEPT                      -m comment --comment "Smurf attck"
	echo "- Protection SMURF : [`color 32 "OK"`]"


	## No Broadcast / Multicast / Invalid and Bogus
	${IPTABLES} -A SECURITY -m pkttype --pkt-type broadcast -j ${LOGFLAGS} "[iptables] [:broadcast:]"                                  -m comment --comment "No broadcast"
	${IPTABLES} -A SECURITY -m pkttype --pkt-type broadcast -j DROP                                                                    -m comment --comment "No Broadcast"
	${IPTABLES} -A SECURITY -m pkttype --pkt-type multicast -j ${LOGFLAGS} "[iptables] [:multicast:]"                                  -m comment --comment "No multicast"
	${IPTABLES} -A SECURITY -m pkttype --pkt-type multicast -j DROP                                                                    -m comment --comment "No multicast"
	${IPTABLES} -A SECURITY -m state --state INVALID -j ${LOGFLAGS} "[iptables] [:invalid:]"                                           -m comment --comment "Invalid"
	${IPTABLES} -A SECURITY -m state --state INVALID -j DROP                                                                           -m comment --comment "Invalid"
	${IPTABLES} -A SECURITY -p tcp -m tcp --tcp-flags SYN,FIN SYN,FIN -j ${LOGFLAGS} "[iptables] [:bogus:]"                            -m comment --comment "Invalid"
	${IPTABLES} -A SECURITY -p tcp -m tcp --tcp-flags SYN,FIN SYN,FIN -j DROP                                                          -m comment --comment "Invalid"
	${IPTABLES} -A SECURITY -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j ${LOGFLAGS} "[iptables] [:bogus:]"                            -m comment --comment "Invalid"
	${IPTABLES} -A SECURITY -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP                                                          -m comment --comment "Invalid"
	echo "- No Broadcast / Multicast / Invalid and Bogus : [`color 32 "OK"`]"

	## REJECT les fausses connex pretendues s'initialiser et sans syn
	${IPTABLES} -A SECURITY -p tcp ! --syn -m state --state NEW,INVALID -j ${LOGFLAGS} "[iptables] [:falsenosyn:]"                     -m comment --comment "NoSyn"
	${IPTABLES} -A SECURITY -p tcp ! --syn -m state --state NEW,INVALID -j DROP                                                        -m comment --comment "NoSyn"
	echo "- Rejeter les fakes de connection, pas de syn : [`color 32 "OK"`]"

	## Furtive port scanner
	${IPTABLES} -A SECURITY -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ${LOGFLAGS} "[iptables] [:furtiveportscan:]" -m comment --comment "Furt. port scan"
	${IPTABLES} -A SECURITY -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT                                      -m comment --comment "Furt. port scan"
	echo "- Block furtive port scanner : [`color 32 "OK"`]"

	## ping of death.. et output ping.
	${IPTABLES} -A SECURITY -p icmp -m icmp --icmp-type address-mask-request -j ${LOGFLAGS} "[iptables] [:badicmp:]"                   -m comment --comment "Bad icmp"
	${IPTABLES} -A SECURITY -p icmp -m icmp --icmp-type address-mask-request -j DROP                                                   -m comment --comment "Bad icmp"
	${IPTABLES} -A SECURITY -p icmp -m icmp --icmp-type timestamp-request -j ${LOGFLAGS} "[iptables] [:badicmp:]"                      -m comment --comment "Bad icmp"
	${IPTABLES} -A SECURITY -p icmp -m icmp --icmp-type timestamp-request -j DROP                                                      -m comment --comment "Bad icmp"
	${IPTABLES} -A SECURITY -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 5 -j ${LOGFLAGS} "[iptables] [:smurfddos:]" -m comment --comment "Limit ping"
	${IPTABLES} -A SECURITY -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 5 -j ACCEPT                            -m comment --comment "Limit ping"
	${IPTABLES} -A SECURITY -p icmp --icmp-type echo-request -j DROP                                                                   -m comment --comment "Limit ping"
	${IPTABLES} -A OUTPUT -p icmp -j ACCEPT                                                                                            -m comment --comment "Ping to inet OK"
	echo "- Block Ping'o'Death : [`color 32 "OK"`]"
	echo "- Autoriser ping sortant : [`color 32 "OK"`]"

	## Ne pas casser les connexions etablies
	${IPTABLES} -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
	${IPTABLES} -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
	echo "- Ne pas casser les connexions etablies : [`color 32 "OK"`]"

	## Bloquer les nouvelles connexions sortantes du user www-data, nous avons precedement autorise les connexions pre etablies
	#${IPTABLES} -A OUTPUT -m owner --uid-owner www-data -j ${LOGFLAGS}  "[iptables] [:badicmp:]"                                       -m comment --comment "Illegal connexion"
        #${IPTABLES} -A OUTPUT -m owner --uid-owner www-data -j DROP
	#echo "- Bloquer les nouvelles connexions sortantes du user www-data : [`color 32 "OK"`]"

	#----- Debut des r?gles  ------------------------------------------------#

	${IPTABLES} -A THISISPORN -s 82.227.212.85 -j DROP   -m comment --comment "Scanned me"
	${IPTABLES} -A THISISPORN -s 83.206.67.226 -j DROP   -m comment --comment "Scanned me"
	${IPTABLES} -A THISISPORN -s 194.74.174.1 -j DROP    -m comment --comment "Scanned me"

	# Autoriser IPSEC-ESP IPSEC-AH
	#${IPTABLES} -A SERVICES --proto 50 -j ACCEPT
	#${IPTABLES} -A SERVICES --proto 51 -j ACCEPT
	#${IPTABLES} -A SERVICES -p udp --dport 500 -j ACCEPT
	#${IPTABLES} -A SERVICES -p udp --dport 1701 -j ACCEPT
	#${IPTABLES} -A SERVICES -p udp --dport 4500 -j ACCEPT
	# routemoica..
	#${IPTABLES} -A INPUT -i ppp+ -j ACCEPT 
	#${IPTABLES} -A OUTPUT -o ppp+ -j ACCEPT 
	#${IPTABLES} -A FORWARD -i ppp+ -j ACCEPT
	#${IPTABLES} -A FORWARD -o ppp+ -j ACCEPT
	#${IPTABLES} -t nat -A POSTROUTING -o eth0 -j MASQUERADE
	#${IPTABLES} -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE
	#echo "- Autoriser L2TP/IPSEC : [`color 32 "ENABLED"`]"

	# Autoriser SSH
	${IPTABLES} -A SERVICES -p tcp --dport 22 -j ACCEPT                              -m comment --comment "sshd"
	echo "- Autoriser SSH : [`color 32 "OK"`]"

	# Autoriser les requetes DNS
	#DISABLED ${IPTABLES} -A SERVICES -p tcp --dport 53 -j ACCEPT                                     -m comment --comment "bind"
	#DISABLED ${IPTABLES} -A SERVICES -p udp --dport 53 -j ACCEPT                                     -m comment --comment "bind"
	echo "- Autoriser les requetes DNS : [`color 33 "DISABLED"`]"

	# Autoriser les requetes HTTP
	${IPTABLES} -A SERVICES -p tcp --dport 80 -j ACCEPT                                               -m comment --comment "http"
	${IPTABLES} -A SERVICES -p tcp --dport 443 -j ACCEPT                                              -m comment --comment "https"
	echo "- Autoriser les requetes HTTP/S : [`color 32 "OK"`]"

	# Autoriser NTP 
	${IPTABLES} -A SERVICES -p udp --dport 123 -j ACCEPT                                              -m comment --comment "ntpd"
	echo "- Autoriser NTP : [`color 32 "OK"`]"

	# ZNC-BNC
	${IPTABLES} -A SERVICES -p tcp --dport 5001 -j ACCEPT                                             -m comment --comment "bouncer/irc"
	echo "- Autoriser ZNC-BNC : [`color 32 "OK"`]"

	# Mail
	${IPTABLES} -A SERVICES -p tcp --dport 25 -j ACCEPT                                               -m comment --comment "smtp"
	#DISABLED ${IPTABLES} -A SERVICES -p tcp --dport 110 -j ACCEPT                                    -m comment --comment "pop3"
	#DISABLED ${IPTABLES} -A SERVICES -p tcp --dport 143 -j ACCEPT                                    -m comment --comment "imap"
	${IPTABLES} -A SERVICES -p tcp --dport 993 -j ACCEPT                                              -m comment --comment "imaps"
	echo "- Autoriser serveur Mail : [`color 33 "POP: DISABLED"`, `color 32 "SMTP/IMAPs: OK"`]"

	# Autoriser les requetes MySQL
	#${IPTABLES} -A SERVICES -p udp -s 1.1.1.1 --dport 3306 -j ACCEPT                            -m comment --comment "mysqld"
	#echo "- Autoriser les requetes MySQL - SSF.fr : [`color 32 "OK"`]"

	#TS Server
	#${IPTABLES} -A SERVICES -p udp --dport 8765 -j ACCEPT                                             -m comment --comment "teamspeak"
	#${IPTABLES} -A SERVICES -p udp --dport 8766 -j ACCEPT                                             -m comment --comment "teamspeak"
	#${IPTABLES} -A SERVICES -p udp --dport 8767 -j ACCEPT                                             -m comment --comment "teamspeak"
	#${IPTABLES} -A SERVICES -p udp --dport 8768 -j ACCEPT                                             -m comment --comment "teamspeak"
	#${IPTABLES} -A SERVICES -p udp --dport 8769 -j ACCEPT                                             -m comment --comment "teamspeak"
	#${IPTABLES} -A SERVICES -p tcp --dport 14534 -j ACCEPT                                            -m comment --comment "teamspeak"
	#${IPTABLES} -A SERVICES -p tcp --dport 51234 -j ACCEPT                                            -m comment --comment "teamspeak"
	#echo "- Autoriser serveur TS : [`color 32 "OK"`]"


	#----- Fin des r?gles  --------------------------------------------------#


	# Ecriture de la politique de log
	# Ici on affiche [IPTABLES DROP] dans /var/log/messages a chaque paquet rejette par iptables
	${IPTABLES} -N LOG_DROP
	${IPTABLES} -A LOG_DROP -j ${LOGFLAGS} '[iptables] [:finaldrop:]'
	${IPTABLES} -A LOG_DROP -j DROP

	# On met en place les logs en entree, sortie et routage selon la politique LOG_DROP ecrit avant
	${IPTABLES} -A FORWARD -j LOG_DROP
	${IPTABLES} -A OUTPUT -j ACCEPT
	${IPTABLES} -A OUTPUT -j LOG_DROP
	${IPTABLES} -A INPUT -j LOG_DROP
	#
	${IPTABLES} -I INPUT -i ${IF_EXT} -j SERVICES
	#
	${IPTABLES} -I INPUT -i ${IF_EXT} -j SECURITY
	#
	${IPTABLES} -I INPUT  -j THISISPORN
	${IPTABLES} -I OUTPUT -j THISISPORN
	echo "- Mise en place des politiques pr?dedement d?finies : [`color 32 "OK"`]"

	## PSAD fifo
	#${IPTABLES} -A INPUT -j LOG --log-tcp-options --log-tcp-sequence --log-ip-options --log-level info
	#echo "- PSAD FIFO : [`color 32 "OK"`]"

	##
	echo ">Starting Fail2Ban"
	sleep 5
	/etc/init.d/fail2ban start
	sleep 2

	echo "- Fail2Ban actives modules: "
	echo `iptables -L -nv --line-numbers | grep -e "Chain fail2ban-"`

	echo "`color 32 ">Firewall mis a jour avec succes !"`"

	######################################################################
	log_end_msg $?
	;;	
	
    stop)
	log_begin_msg "Flushing rules..."
	## Vider les tables actuelles
	${IPTABLES} -t filter -F
	${IPTABLES} -t filter -X
	${IPTABLES} -t mangle -F
	${IPTABLES} -t mangle -X
	${IPTABLES} -t nat -F
	${IPTABLES} -t nat -X
	${IPTABLES} -F
	${IPTABLES} -X
	${IPTABLES} -Z
	${IPTABLES} -A INPUT -j ACCEPT
	${IPTABLES} -A OUTPUT -j ACCEPT
	${IPTABLES} -A FORWARD -j ACCEPT
	log_end_msg $?
	;;
	
	
	restart)
	$0 stop
	$0 start
	;;
    
		
	
    status)
	${IPTABLES} -nvL
	;;


    *)
	log_success_msg "Usage: /etc/init.d/firewall {start|stop|restart|status}"
	exit 1
	;;
esac

exit 0
