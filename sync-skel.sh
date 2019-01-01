#!/bin/sh

# need git for this to work
[ ! $( which git ) ] && echo "missing git" && exit 99

# grab skel repo
git clone https://github.com/gpanula/skel.git  /tmp/skel.$$
cd /tmp/skel.$$
git checkout master
rm -f LICENSE
rm -f README.md
cp -f .bashrc /root/.bashrc

cd /tmp
rsync -ah --exclude ".git*" /tmp/skel.$$/ /etc/skel/

echo skel syncd with github repo | logger

rm -rf /tmp/skel.$$

exit
