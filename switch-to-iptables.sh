#!/bin/sh

# switch from firewalld to iptables
# https://www.certdepot.net/rhel7-disable-firewalld-use-iptables/

yum install -y iptables-services
systemctl mask firewalld
systemctl enable iptables
systemctl enable ip6tables

systemctl stop firewalld
systemctl start iptables
systemctl start ip6tables

# now put base iptable rules in place
cd /etc/sysconfig
[ -e /etc/sysconfig/iptables ] && mv /etc/sysconfig/iptables /etc/sysconfig/iptables.orig
wget -O /etc/sysconfig/iptables https://raw.githubusercontent.com/gpanula/server_base/master/iptables
ip addr | grep inet | grep -v inet6 | grep -v 127.0.0.1 | grep -iv tun | awk '{ print $2 }' | cut -d'/' -f1 | sed 's/.*/s\/LOCALIPADDRESS\/&\//' > /tmp/build/ipv4
sed -f /tmp/build/ipv4 -i /etc/sysconfig/iptables
chmod 600 /etc/sysconfig/iptables

[ -e /etc/sysconfig/ip6tables ] && mv /etc/sysconfig/ip6tables /etc/sysconfig/ip6tables.orig
cp /etc/sysconfig/iptables /etc/sysconfig/iptables.backup
wget -O /etc/sysconfig/ip6tables https://raw.githubusercontent.com/gpanula/server_base/master/ip6tables
ip addr | grep inet6 | grep -v ::1/128 | grep -iv tun | awk '{ print $2 }' | head -n 1 | cut -d'/' -f1 | sed 's/.*/s\/LOCALIPADDRESS\/&\//' > /tmp/build/ipv6
sed -f /tmp/build/ipv6 -i /etc/sysconfig/ip6tables
chmod 600 /etc/sysconfig/ip6tables

exit 0
