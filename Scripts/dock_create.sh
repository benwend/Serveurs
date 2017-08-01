#!/bin/bash

NAME="linuxserver/piwigo"
DOCKER="piwigo"
LOCAL="/srv/data/piwigo"
DIST="/config"
PGID=1000
PUID=1000
PORTL=443
PORTD=443

docker create \
--name=$DOCKER \
-v /etc/localtime:/etc/localtime:ro \
-v $LOCAL:$DIST \
-e PGID=$PGID -e PUID=$PUID  \
-e TZ="Europe/Paris" \
-p $PORTL:$PORTD \
$NAME
