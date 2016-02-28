#!/bin/sh

PROJECTDIR=/project

export DEBIAN_FRONTEND=noninteractive

apt-get update

# base (vim, python2.7 is already installed at ubuntu box)
apt-get -q -y install vim screen python2.7

apt-get -q -y install postfix

iptables-restore < /vagrant/vagrantdata/worker/iptables.sav

apt-get -q -y install git

# clone repo
if [ ! -d $PROJECTDIR/rummager ]; then

	git clone https://github.com/lbacik/rummager.git $PROJECTDIR/rummager

	# app configuration	
	cd $PROJECTDIR/rummager
	cat config.py | tr '\n' '|' | \
		sed 's/^\(.*\)__HOST__\(.*\)$/\1rumsrv.local\2/g' | \
		tr '|' '\n' > config.py.new
	mv config.py.new config.py
	cd
	mkdir $PROJECTDIR/logs
fi

# install required python libraries
apt-get -q -y install python-pip

pip install suds
pip install netaddr

# hosts
echo '192.168.33.20 rumsrv.local' >> /etc/hosts

