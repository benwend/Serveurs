#!/bin/bash
#
# My own script to check /proc
#
# Benwend - 06/2015
# GPLv3
#
# Syntaxe: # ./check_proc.sh
#
VERSION="0.1"

##############################

### KERNEL
# kernel.core_uses_pid
echo "1" > /proc/sys/kernel/core_uses_pid

# kernel.kptr_restrict
echo "1" > /proc/sys/kernel/kptr_restrict

# kernel.sysrq
echo "0" > /proc/sys/kernel/sysrq

### NETWORK
## IPv4
# Smurf Attack
echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# Source routing
echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# Syn Flood
echo "1" > /proc/sys/net/ipv4/tcp_syncookies
echo "1024" > /proc/sys/net/ipv4/tcp_max_syn_backlog
echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter

# Redirects
echo "0" > /proc/sys/net/ipv4/conf/default/accept_redirects
echo "0" > /proc/sys/net/ipv4/conf/default/secure_redirects

echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects
echo "0" > /proc/sys/net/ipv4/conf/all/secure_redirects

# Bad error messages
echo "1" > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses

# Log Martians
echo "1" > /proc/sys/net/ipv4/conf/default/log_martians
echo "1" > /proc/sys/net/ipv4/conf/all/log_martians

# RP Filter
echo "1" > /proc/sys/net/ipv4/conf/default/rp_filter
echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter

# Source Route
echo "0" > /proc/sys/net/ipv4/conf/default/accept_source_route
echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route

# Time stamps
echo "0" > /proc/sys/net/ipv4/tcp_timestamps

# Send redirects
echo "0" > /proc/sys/net/ipv4/conf/default/send_redirects
echo "0" > /proc/sys/net/ipv4/conf/all/send_redirects


## IPv6
# Redirects
echo "0" > /proc/sys/net/ipv6/conf/default/accept_redirects
echo "0" > /proc/sys/net/ipv6/conf/all/accept_redirects

# Source Route
echo "0" > /proc/sys/net/ipv6/conf/default/accept_source_route
echo "0" > /proc/sys/net/ipv6/conf/all/accept_source_route