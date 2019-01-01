#!/bin/sh

# need git for this to work
[ ! $( which git ) ] && echo "missing git" && exit 99

# grab profile.d repo
git clone https://github.com/gpanula/profile.d.git  /tmp/profile.d.$$
cd /tmp/profile.d.$$
git checkout master
# sub module ref: https://blog.github.com/2016-02-01-working-with-submodules/
git submodule update --init --recursive

cd /tmp
rsync -ah --exclude ".git*" /tmp/profile.d.$$/ /etc/profile.d/

echo profile.d syncd with github repo | logger

rm -rf /tmp/profile.d.$$

exit
