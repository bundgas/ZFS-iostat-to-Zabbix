#!/bin/sh
# Written by Søren Sørensen and Kenneth Lutzke.
#
# This script will send zpool iostat output to your Zabbix server at a given interval.
# Put this to run at startup and/or in crontab.
# You will need to set the check up as "trapper" in Zabbix.
# This script outputs in bytes.
# The names of the checks are:
# zfs.zpool.iostat.write.bandwidth
# zfs.zpool.iostat.read.bandwidth
# zfs.zpool.iostat.write.ops
# zfs.zpool.iostat.read.ops

PATH=/usr/bin:/sbin:/bin

zfs_pool="tank" # Pool to check
interval="60" # zpool iostat interval in seconds. Suggested value is 60.
zabbix_server="zabbix.example.com" # Zabbix-server to send to
zabbix_sender="/usr/bin/zabbix_sender" # Path to zabbix sender
zabbix_conf="/etc/zabbix/zabbix_agentd.conf" # Path to zabbix-agentd.conf

if ! [ -n "$(pgrep -f "zfs.zpool.iostat.write.bandwidth")" ]; then
zpool iostat $zfs_pool $interval | stdbuf -o0 awk 'NR > 3 {print($7)}' | stdbuf -o0 sed -e 's/K/\*1024/g' -e 's/M/\*1048576/g' -e 's/G/\*1073741824/g' | bc | stdbuf -o0 awk '{printf("%d\n",$1 + 0.5)}' | xargs -L 1 $zabbix_sender -z $zabbix_server -c $zabbix_conf -k zfs.zpool.iostat.write.bandwidth -o &
fi

if ! [ -n "$(pgrep -f "zfs.zpool.iostat.read.bandwidth")" ]; then
zpool iostat $zfs_pool $interval | stdbuf -o0 awk 'NR > 3 {print($6)}' | stdbuf -o0 sed -e 's/K/\*1024/g' -e 's/M/\*1048576/g' -e 's/G/\*1073741824/g' | bc | stdbuf -o0 awk '{printf("%d\n",$1 + 0.5)}' | xargs -L 1 $zabbix_sender -z $zabbix_server -c $zabbix_conf -k zfs.zpool.iostat.read.bandwidth -o &
fi

if ! [ -n "$(pgrep -f "zfs.zpool.iostat.write.ops")" ]; then
zpool iostat $zfs_pool $interval | stdbuf -o0 awk 'NR > 3 {print($5)}' | stdbuf -o0 sed -e 's/K/\*1024/g' -e 's/M/\*1048576/g' -e 's/G/\*1073741824/g' | bc | stdbuf -o0 awk '{printf("%d\n",$1 + 0.5)}' | xargs -L 1 $zabbix_sender -z $zabbix_server -c $zabbix_conf -k zfs.zpool.iostat.write.ops -o &
fi

if ! [ -n "$(pgrep -f "zfs.zpool.iostat.read.ops")" ]; then
zpool iostat $zfs_pool $interval | stdbuf -o0 awk 'NR > 3 {print($4)}' | stdbuf -o0 sed -e 's/K/\*1024/g' -e 's/M/\*1048576/g' -e 's/G/\*1073741824/g' | bc | stdbuf -o0 awk '{printf("%d\n",$1 + 0.5)}' | xargs -L 1 $zabbix_sender -z $zabbix_server -c $zabbix_conf -k zfs.zpool.iostat.read.ops -o &
fi
