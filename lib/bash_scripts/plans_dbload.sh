#!/bin/bash
# Performs an update to the funds DB in PCO Dashboard
export LOGFILEPREFIX="plans"

cd /var/www
/root/.rbenv/shims/rails runner /var/www/lib/$LOGFILEPREFIX-dbload.rb
#for maintenance, also check and delete any funds logs older than 30 days
find /var/www/log/$LOGFILEPREFIX* -mtime +30 -type f -delete
