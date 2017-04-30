#!/bin/bash
#
# My own script to check /proc
#
# Author: Benwend - 30/04/2017
# Licence: GPLv3
# Syntaxe: # ./check_proc.sh
# Version: 1.1
#
##############################

#########
### KERNEL
# kernel.core_uses_pid
sysctl -w kernel.core_uses_pid=1;

# kernel.kptr_restrict
sysctl -w kernel.kptr_restrict=1;

# kernel.sysrq
sysctl -w kernel.sysrq=0;

##########
### NETWORK
## IPv4
# Smurf Attack
sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1;

# Syn Flood
sysctl -w net.ipv4.tcp_syncookies=1;
sysctl -w net.ipv4.tcp_max_syn_backlog=1024;
sysctl -w net.ipv4.conf.all.rp_filter=1;

# Redirects
sysctl -w net.ipv4.conf.default.accept_redirects=0;
sysctl -w net.ipv4.conf.default.secure_redirects=0;

sysctl -w net.ipv4.conf.all.accept_redirects=0;
sysctl -w net.ipv4.conf.all.secure_redirects=0;

# Bad error messages
sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1;

# Log Martians
sysctl -w net.ipv4.conf.default.log_martians=1;
sysctl -w net.ipv4.conf.all.log_martians=1;

# RP Filter
sysctl -w net.ipv4.conf.default.rp_filter=1;
sysctl -w net.ipv4.conf.all.rp_filter=1;

# Source Route
sysctl -w net.ipv4.conf.default.accept_source_route=0;
sysctl -w net.ipv4.conf.all.accept_source_route=0;

# Time stamps
sysctl -w net.ipv4.tcp_timestamps=0;

# Send redirects
sysctl -w net.ipv4.conf.default.send_redirects=0;
sysctl -w net.ipv4.conf.all.send_redirects=0;

#IP Forwarding
sysctl -w net.ipv4.conf.all.forwarding=0;


## IPv6
# Redirects
sysctl -w net.ipv6.conf.default.accept_redirects=0;
sysctl -w net.ipv6.conf.all.accept_redirects=0;

# Source Route
sysctl -w net.ipv6.conf.default.accept_source_route=0;
sysctl -w net.ipv6.conf.all.accept_source_route=0;

# IP Forwarding
sysctl -w net.ipv6.conf.all.forwarding=0;
