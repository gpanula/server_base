#!/bin/sh 

yum -y install unzip wget vim-enhanced bind-utils net-tools
mkdir /tmp/build
wget -O /tmp/build/skel.zip https://github.com/gpanula/skel/archive/master.zip
cd /etc
unzip /tmp/build/skel.zip
mv /etc/skel /etc/skel.orig
mv /etc/skel-master /etc/skel
rm /etc/skel/LICENSE 
rm /etc/skel/.LICENSE
rm /etc/skel/README.md
chmod 640 /etc/skel/.ssh/authorized_keys2

cd /root
mv .bashrc .bashrc.orig
cp /etc/skel/.bashrc /root/.bashrc

wget -O /tmp/build/profile.d.zip https://github.com/gpanula/profile.d/archive/master.zip
cd /tmp/build
unzip /tmp/build/profile.d.zip
cp /tmp/build/profile.d-master/* /etc/profile.d/
rm /etc/profile.d/README.md

cd /etc/ssh
mv sshd_config sshd_config.orig
wget -O /etc/ssh/sshd_config https://raw.githubusercontent.com/gpanula/server_base/master/sshd_config
chmod 600 /etc/ssh/sshd_config
iptables -I INPUT 1 -p tcp -m tcp --dport 4242 -m state --state NEW -m comment --comment "Allow SSH" -j ACCEPT

cd /etc/sysconfig
[ -e /etc/sysconfig/iptables ] && mv /etc/sysconfig/iptables /etc/sysconfig/iptables.orig
wget -O /etc/sysconfig/iptables https://raw.githubusercontent.com/gpanula/server_base/master/iptables
chmod 600 /etc/sysconfig/iptables

[ -e /etc/sysconfig/ip6tables ] && mv /etc/sysconfig/ip6tables /etc/sysconfig/ip6tables.orig
cp /etc/sysconfig/iptables /etc/sysconfig/iptables.backup
wget -O /etc/sysconfig/ip6tables https://raw.githubusercontent.com/gpanula/server_base/master/ip6tables
chmod 600 /etc/sysconfig/ip6tables

exit 0
