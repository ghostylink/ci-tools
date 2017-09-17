#/bin/bash -e

source /image/db.sh

if [[ ! -d "$TESTED_CODE/bin" ]]; then
    # Considere current directory as the code to be tested
    if [[ "$BUILD_TAG" == "" ]]; then
        export TESTED_CODE="."
    else
        export TESTED_CODE="$PWD"
    fi
    echo "tested code $TESTED_CODE"
fi    

if ! db_volume_exist; then    
    echo -e "\t=> Installing MySQL volume ...\n"        
    
    db_wait_until_ready

    db_create_user "$TESTED_CODE"
    db_create "$TESTED_CODE" "ghostylink_test_template"
    db_create "$TESTED_CODE" "ghostylink_test"
    CI_SERVER=1 "$TESTED_CODE"/bin/cake migrations migrate -c test_schema
else
    db_wait_until_ready
fi

# For future // tests running
#for ((i=0; i<=3; i++)); do
#    # Create a new database
#    db_name="ghostylink_ci_$i"
#    echo -e "\t=> Creating CI database $db_name\n"    
#    db_create "/code_tested/" "$db_name"
#
#done 