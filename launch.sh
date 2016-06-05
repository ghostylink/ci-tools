#!/bin/bash -e

source "/image/db.sh"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
        -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini

if ! db_volume_exist; then    
    echo -e "\t=> Installing MySQL volume ...\n"

    mysql_install_db > /dev/null 2>&1
    db_wait_until_ready

    db_create_user "/code_tested"
    db_create "/code_tested" "ghostylink_test_template"
    db_create "/code_tested/" "ghostylink_test"
    CI_SERVER=1 /code_tested/bin/cake migrations migrate -c test_schema
else
    db_wait_until_ready
fi

cd /code_tested
#composer install
# For future // tests running
#for ((i=0; i<=3; i++)); do
#    # Create a new database
#    db_name="ghostylink_ci_$i"
#    echo -e "\t=> Creating CI database $db_name\n"    
#    db_create "/code_tested/" "$db_name"
#
#done 

mysqladmin -uroot shutdown
exec supervisord -n