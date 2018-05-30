#!/bin/sh 

yum -y install unzip wget vim-enhanced bind-utils net-tools rsync policycoreutils-python

mkdir /tmp/build
wget -O /tmp/build/skel.zip https://github.com/gpanula/skel/archive/master.zip
cd /etc
unzip /tmp/build/skel.zip
mv /etc/skel /etc/skel.orig
mv /etc/skel-master /etc/skel
rm -f /etc/skel/LICENSE 
rm -f /etc/skel/.LICENSE
rm -f /etc/skel/README.md
chmod 640 /etc/skel/.ssh/authorized_keys2

cd /root
mv .bashrc .bashrc.orig
cp /etc/skel/.bashrc /root/.bashrc
sed -i '/set-git-info/s/^/#/' /root/.bashrc

wget -O /tmp/build/profile.d.zip https://github.com/gpanula/profile.d/archive/master.zip
cd /tmp/build
unzip /tmp/build/profile.d.zip
cp /tmp/build/profile.d-master/* /etc/profile.d/
rm -f /etc/profile.d/README.md

cd /etc/ssh
mv sshd_config sshd_config.orig
wget -O /etc/ssh/sshd_config https://raw.githubusercontent.com/gpanula/server_base/master/sshd_config
chmod 600 /etc/ssh/sshd_config
awk '$5 >= 3071' /etc/ssh/moduli > /etc/ssh/moduli.tmp && mv /etc/ssh/moduli /etc/ssh/moduli.OLD && mv /etc/ssh/moduli.tmp /etc/ssh/moduli

if [ ! -z "$( which firewall-cmd )" ]
then
    echo Found firewall-cmd, going to use it
    cp /usr/lib/firewalld/services/ssh.xml /usr/lib/firewalld/services/ssh4242.xml
    sed 's/SSH/SSH4242/' -i /usr/lib/firewalld/services/ssh4242.xml
    sed 's/22/4242/' -i /usr/lib/firewalld/services/ssh4242.xml
    $( which firewall-cmd ) --permanent --zone=public --add-service ssh4242
    $( which firewall-cmd ) --reload
else
    echo Firewall-cmd not found, going to use straight iptables
    iptables -I INPUT 1 -p tcp -m tcp --dport 4242 -m state --state NEW -m comment --comment "Allow SSH" -j ACCEPT
fi

# allow sshd to listen on port 4242
semanage port -a -t ssh_port_t -p tcp 4242

[ -e /etc/motd ] && mv /etc/motd /etc/motd.orig
wget -O /etc/motd https://raw.githubusercontent.com/gpanula/server_base/master/motd


exit 0
