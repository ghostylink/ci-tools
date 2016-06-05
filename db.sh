#!/bin/bash -e
if [[ $SCRIPT_DEV ]]; then
    set -x
fi

## Wait until mysql database is ready
function db_wait_until_ready {
    /usr/bin/mysqld_safe > /dev/null 2>&1 &
    RET=1
    echo -e "\t=> Waiting for confirmation of MySQL service startup\n"
    while [[ RET -ne 0 ]]; do
        printf '.'
        sleep 5
        mysql -uroot -e "status" > /dev/null 2>&1
        RET=$?
    done
}

## Upgrade the database schema
## @param $1 ghostylink install directory
## @return void
function db_upgrade {
    local installDir=$1    
    $installDir/bin/cake migrations migrate
}

## Check if db exist 
## @return true if the db exist, false otherwise
function db_volume_exist { 
    local VOLUME_HOME="/var/lib/mysql"
    if [[ ! -d $VOLUME_HOME/mysql ]]; then
        return 1
    else
        return 0
    fi
}

## Create the ghostylink database. The user is supposed to be already created
## @param $1 ghostylink install directory
## @return void
function db_create_user {
    local installDir="$1"
    printf "\t=> Reading configuration from '$installDir'"    
    local db_user=$(db_get_conf_for "$installDir" "username")    
    local db_pwd=$(db_get_conf_for "$installDir" "password")

    echo "\t=> Creating MySQL '$db_user' user with password '$db_pwd'\n"
    mysql -uroot -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pwd'"
    echo "\t=> User created\n"
}

## Create the ghostylink database. The user is supposed to be already created
## @param $1 ghostylink install directory
## @param $2 The database name
## @return void
function db_create {
    local installDir=$1
    local db_name="$2"

    if [[ db_name == "" ]]; then
        db_name=$(db_get_conf_for "$installDir" "database")
    fi

    echo "\t=> Reading configuration from '$installDir\n'"    
    local db_user=$(db_get_conf_for "$installDir" "username")
    local db_pwd=$(db_get_conf_for "$installDir" "password")
    
    echo "\t=> Creating MySQL database $db_name\n"
    mysql -uroot -e "CREATE DATABASE $db_name"
    mysql -uroot -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost' WITH GRANT OPTION"

    echo "=> Creation of database '$db_name' Done!"
}

## Check if version A is before version B
## @param $1 version A
## @param $2 version B
## @return 1 if A < B, 2 if A > B, 0 if A == B
function db_version_cmp {
    if [[ "$1" < "$2" ]]; then
        return 1
    elif [[ "$1" > "$2" ]]; then
        return 2
    else
        return 0
    fi
}

## Check if a version is before an other
## @param $1 version supposed to be before
## @param $2 version supposed to be after
## @return true if $1 is before $2. False otherwise
function db_version_is_before {    
    $(db_version_cmp "$1" "$2")
    local ret=$?    
    if [[ $ret -eq 1 ]]; then        
        return 0
    else
        return 1
    fi    
}

## Check if a version is after an other
## @param $1 version supposed to be after
## @param $2 version supposed to be before
## @return true if $1 is after $2. False otherwise
function db_version_is_after {
    $(db_version_cmp "$1" "$2")
    local ret=$?    
    if [[ $ret -eq 2 ]]; then        
        return 0
    else
        return 1
    fi    
}

## Get current version of the migrations (in the database)
## @param $1 ghostylink install directory
## @return print to stdout the installed version 
function db_get_version {
    local installDir=$1
    local db_name=$(db_get_conf_for "$installDir" "database")
    local db_user=$(db_get_conf_for "$installDir" "username")
    local db_pwd=$(db_get_conf_for "$installDir" "password")
    
    local sql="SELECT version FROM phinxlog ORDER BY version DESC LIMIT 1"
    # Do not print line header. Run in Batch mode
    version=$(mysql -u$db_user -p$db_pwd -D$db_name -N -B -e "$sql")
    echo $version
}

## Retrieve the current expected version in the container
## @param $1 ghostyink install directory
## @return print to stdout the expected migration version
function db_get_expected_version {
    local installDir=$1
    migrationsDir="$installDir/config/Migrations"
    version=$(ls -1 -r -v $migrationsDir| grep -Po '^\d+'| head -n 1)
    echo $version
}

## Retrieve a configuration value
## @param $1 ghostylink install directory
## @param $2 key to retrieve
## @return print to stdout the value for the key in the conf file
function db_get_conf_for {
    local installDir=$1
    local key=$2
    local phpStatement="\$conf = require '$installDir/config/app_tests.php'; \
                         print_r(\$conf['Datasources']['test']['$key']);"    
    local val=$(php -r "$phpStatement")
    echo "$val"
}