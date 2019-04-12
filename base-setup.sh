#!/bin/sh

sysctl=$( which systemctl )

yum -y install unzip wget vim-enhanced bind-utils net-tools rsync policycoreutils-python rsyslog chrony

# install epel repo
yum -y install epel-release

# install figlet (used by dynamotd)
yum -y install figlet

# install ius repo (mostly for git2)
# ref: https://ius.io/GettingStarted/
yum -y install https://centos7.iuscommunity.org/ius-release.rpm

# install firewalld
yum -y install firewalld
$sysctl enable firewalld
$sysctl start firewalld

mkdir /tmp/build
wget -O /tmp/build/skel.zip https://github.com/gpanula/skel/archive/master.zip
cd /etc || exit 99
unzip /tmp/build/skel.zip
mv /etc/skel /etc/skel.orig
mv /etc/skel-master /etc/skel
rm -f /etc/skel/LICENSE
rm -f /etc/skel/.LICENSE
rm -f /etc/skel/README.md
chmod 640 /etc/skel/.ssh/authorized_keys2

cd /root || exit 99
mv .bashrc .bashrc.orig
cp /etc/skel/.bashrc /root/.bashrc
cp /etc/skel/.vimrc /root/.vimrc
sed -i '/set-git-info/s/^/#/' /root/.bashrc
mkdir /root/.ssh
chmod 0600 /root/.ssh
cp /etc/skel/.ssh/authorized_keys2 /root/.ssh/authorized_keys2
ln -s /root/.ssh/authorized_keys2 /root/.ssh/authorized_keys

wget -O /tmp/build/profile.d.zip https://github.com/gpanula/profile.d/archive/master.zip
cd /tmp/build || exit 99
unzip /tmp/build/profile.d.zip
cp /tmp/build/profile.d-master/* /etc/profile.d/
rm -f /etc/profile.d/README.md

cd /etc/ssh || exit 99
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
# Put "dynamic" motd in place
wget -O /usr/local/etc/system-location https://raw.githubusercontent.com/gpanula/server_base/master/system-location
wget -O /usr/local/etc/system-announcement https://raw.githubusercontent.com/gpanula/server_base/master/system-announcement
wget -O /etc/systemd/system/dynamotd.service https://raw.githubusercontent.com/gpanula/server_base/master/dynamotd.service
wget -O /etc/systemd/system/dynamotd.timer https://raw.githubusercontent.com/gpanula/server_base/master/dynamotd.timer
wget -O /usr/local/bin/dynamotd.sh https://raw.githubusercontent.com/gpanula/server_base/master/dynamotd.sh
chmod +x /usr/local/bin/dynamotd.sh
$sysctl daemon-reload
$sysctl enable dynamotd.timer
$sysctl start dynamotd.service
ln -s /var/run/motd /etc/motd

# ditch the unneed firmware
rpm -qa | grep firmware | grep -v linux | xargs yum remove -y

# disable postfix
$sysctl stop postfix
$sysctl disable postfix

# disable rpcbind
$sysctl stop rpcbind
$sysctl disable rpcbind
$sysctl stop rpcbind.socket
$sysctl disable rpcbind.socket

# bug-fix
# ref: https://bugs.centos.org/view.php?id=11228
sed '/ControlGroup/d' -i /usr/lib/systemd/system/watchdog.service
$sysctl daemon-reload

# quick note about cmd-line speedtest
echo "You can check your speed via"
echo "curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"
echo ""
echo "ref: https://askubuntu.com/questions/104755/how-to-check-internet-speed-via-terminal"

echo ""
echo "Remember to update /usr/local/etc/system-location or remove it if running in AWS"
echo ""

exit 0
