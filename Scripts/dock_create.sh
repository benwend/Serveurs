#!/bin/bash

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
