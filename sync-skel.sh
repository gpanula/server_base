#!/bin/sh

# need git for this to work
[ ! $( which git ) ] && echo "missing git" && exit 99

# grab skel repo
git clone https://github.com/gpanula/skel.git  /tmp/skel.$$
cd /tmp/skel.$$
git checkout master
rm -f LICENSE
rm -f README.md

cd /tmp
rsync -ah --exclude ".git*" /tmp/skel.$$/ /etc/skel/

echo skel syncd with github repo | logger

# update root's bits
cp -f /etc/skel/.bashrc /root/.bashrc
cp -f /etc/skel/.vimrc /root/.vimrc
sed -i '/set-git-info/s/^/#/' /root/.bashrc
mkdir /root/.ssh
chmod 0600 /root/.ssh
cp /etc/skel/.ssh/authorized_keys2 /root/.ssh/authorized_keys2
ln -s /root/.ssh/authorized_keys2 /root/.ssh/authorized_keys

echo root dot files updated | logger

rm -rf /tmp/skel.$$

exit
