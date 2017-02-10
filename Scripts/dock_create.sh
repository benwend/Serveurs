#!/bin/bash
#
################################################################################
#
# Author  : benwend <ben_wend@hotmail.fr>
# Date    : 10/02/2017
# Version : 0.1
# Usage	  : # ./dock_create.sh
# Summary :
#  Sample script for install a docker container.
#
################################################################################

NAME=""
DOCKER=""
LOCAL=""
DIST=""
PGID=
PUID=
PORTL=
PORTD=

docker create \
--name=$DOCKER \
-v /etc/localtime:/etc/localtime:ro \
-v $LOCAL:$DIST \
-e PGID=$PGID -e PUID=$PUID  \
-e TZ="Europe/Paris" \
-p $PORTL:$PORTD \
$NAME
