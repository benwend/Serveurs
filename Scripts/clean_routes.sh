#! /bin/bash
#
#################################################################################
#                                                                               #
# Author  : benwend <benjamin.wend+git@gmail.com>                               #
# Date    : 30/04/2017                                                          #
# Version : 0.2                                                                 #
# Usage   : # ./clean_routes.sh                                                 #
# Summary  :                                                                    #
#  Cleans the routing table of "unreachable" IP routes                          #
#                                                                               #
#################################################################################
#                                                                               #
# Doc :                                                                         #
#  $ sudo ip route del <MON_IP>                                                 #
#                                                                               #
#################################################################################
#                                                                               #
# 11/03/2016         benwend           Initial release (v0.1)                   #
# 30/04/2017         benwend           Scan with Shellcheck (v0.2)              #
#                                                                               #
#################################################################################

ip route > f1
grep "unreachable" f1 | cut -d" " -f2 > f2
rm f1

while read l
do
    ip route del "$l"
done < f2

rm f2
