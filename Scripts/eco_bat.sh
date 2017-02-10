#!/bin/bash
#
################################################################################
#
# Author  : benwend <ben_wend@hotmail.fr>
# Date    : 10/02/2017
# Version : 0.1
# Usage	  : # ./eco_bat.sh <parameter>
# Summary :
#  Sample script for eco battery
#
################################################################################

function eco {
	systemctl stop cups.path
	systemctl stop cups.socket
	systemctl stop cups-browsed.service
	systemctl stop cups.service
	systemctl stop smbd.service
	systemctl stop nmbd.service
	echo "* services : cups + smbd + nmbd arrêtés !"
}

function portable {
	systemctl stop NetworkManager.service
	systemctl stop ntp.service
	systemctl stop dnsmasq.service
	pkill megasync
	echo "* services : NetworkManager + dnsmasq + ntpd arrêtés !"
	echo "* application : Mega arrêtée !"
}

function std {
	systemctl start NetworkManager.service
	systemctl start dnsmasq.service
	systemctl start smbd.service
	systemctl start nmbd.service
	systemctl start ntp.service
	echo "* services : NetworkManager + dnsmasq + nmbd + smbd + ntpd démarrés !"
}

if [ $# -eq 0 ]
then
	echo "sudo bash $0 portable|eco|standard"
elif [ $1 = "standard" ]
then
	echo "Mode standard :"
	std
else
	if [ $1 = "eco" ]
	then
		echo "Mode éco :"
		eco
	elif [ $1 = "portable" ]
	then
		echo "Mode portable :"
		eco
		portable
	else
		exit 0
	fi
	echo "---------------------"
	netstat -ntaup
fi
