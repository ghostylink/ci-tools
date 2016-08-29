#!/bin/bash -e

source /image/db_init.sh

if [[ "$BUILD_TAG" == "" ]]; then
    ln -s "$TESTED_CODE" /var/www/html/ghostylink
    chmod -R 777 "$TESTED_CODE/tmp"
    chmod -R 777 "$TESTED_CODE/logs"
    sed -i s/__tbr__maildev/"localhost"/ /etc/apache2/sites-available/000-default.conf
else
    cp -R "$TESTED_CODE" /var/www/html/ghostylink
    chown -R www-data:www-data /var/www/html/ghostylink
    sed -i s/__tbr__maildev/"maildev-$BUILD_TAG"/ /etc/apache2/sites-available/000-default.conf
fi
cp /image/apache-conf/default.conf /etc/apache2/sites-available/000-default.conf

service apache2 start