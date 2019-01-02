#!/bin/sh 

yum -y install unzip wget vim-enhanced bind-utils net-tools rsync policycoreutils-python

mkdir /tmp/build
## sync skel
wget -O /tmp/sync-skel.$$ https://raw.githubusercontent.com/gpanula/server_base/different/sync-skel.sh
chmod +x /tmp/sync-skel.$$
/tmp/sync-skel.$$
rm -f /tmp/sync-skel.$$

## sync profile.d
wget -O /tmp/sync-profile.$$ https://raw.githubusercontent.com/gpanula/server_base/different/sync-profile_d.sh
chmod +x /tmp/sync-profile.$$
/tmp/sync-profile.$$
rm -f /tmp/sync-profile.$$

## setup sshd
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
    # need a pause here for firewalld to see the new service
    $( which firewall-cmd ) --reload
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

# ditch the unneed firmware
rpm -qa | grep firmware | grep -v linux | xargs yum remove -y

exit 0
