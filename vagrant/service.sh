#!/bin/sh

PROJECTDIR=/project

apt-get update

# base
apt-get install -q -y vim screen

# mysql
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mysql-server
sed -i 's/^bind-address.*$/bind-address = 0.0.0.0/' /etc/mysql/my.cnf
service mysql restart

# apache + php
apt-get -q -y install apache2 php5 php5-mysql phpunit

# git
apt-get -q -y install git

# clone repo
if [ ! -d $PROJECTDIR/rumsrv ]; then
	git clone -b develop https://github.com/lbacik/rummager-service.git $PROJECTDIR/rumsrv

	# app configuration	
	cd $PROJECTDIR/rumsrv
	cat config.local.php.dist | tr '\n' '|' | \
		sed 's/^\(.*\)HOST\(.*\)DBNAME\(.*\)USER\(.*\)PASS\(.*\)$/\1localhost\2sn\3sn\4rummager\5/g' | \
		tr '|' '\n' > config.local.php
	cd
fi

# DB configuration
cd $PROJECTDIR/rumsrv/sql
mysql -u root < db.sql
mysql -u root -e 'grant all on sn.* to "sn"@"%" identified by "rummager"'
cd

#apache config
cp /vagrant/vagrantdata/service/apache.conf /etc/apache2/sites-available/rumsrv.conf
a2ensite rumsrv
service apache2 restart

# cron
cp /project/rumsrv/cron/rumsrv.cron /etc/cron.d/rumsrv

# hosts
echo '127.0.0.1 rumsrv.local' >> /etc/hosts

###
### risky things
###

# dbunit install
# @FIXME it is not the best way to download/install this package...
wget http://cz.archive.ubuntu.com/ubuntu/pool/universe/p/phpunit-dbunit/phpunit-dbunit_1.3.1-2_all.deb
dpkg -i --force-depends phpunit-dbunit_1.3.1-2_all.deb


