#!/bin/bash -e

source /image/db_init.sh

if [[ "$BUILD_TAG" == "" ]]; then
    ln -s "$TESTED_CODE" /var/www/html/ghostylink
    chmod -R 777 "$TESTED_CODE/tmp"
    chmod -R 777 "$TESTED_CODE/logs"
    sed -i s/__tbr__maildev/"localhost"/ /image/apache-conf/default.conf
else
    ## Legacy check for old ghostylink branches
    if [[ "$BUILD_TAG_SAFE" == "" ]]; then
        BUILD_TAG_SAFE="$BUILD_TAG"
    fi
    ln -s "$TESTED_CODE" /var/www/html/ghostylink
    #chown -R www-data:www-data /var/www/html/ghostylink
    sed -i s/__tbr__maildev/"maildev-$BUILD_TAG_SAFE"/ /image/apache-conf/default.conf
fi
cp /image/commands/* /bin
chmod -R 755 /bin
cp /image/apache-conf/default.conf /etc/apache2/sites-available/000-default.conf
