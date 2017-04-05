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

exit 0
