#!/bin/bash -e
bash /image/init.sh
exec supervisord -n
