#!/bin/bash -e
bash /image/init.sh

ln -s $TESTED_CODE /var/www/html/ghostylink
cp /image/apache-conf/default.conf /etc/apache2/sites-available/000-default.conf
service apache2 start
exec supervisord -n
