#!/bin/bash
# Performs an update to the funds DB in PCO Dashboard
RAILS=$(which rails)
#Delete all existing Crono records
echo $RAILS
$RAILS runner ./lib/crono-wipe.rb

#Restart Crono Daemon

bundle exec crono restart RAILS_ENV=development
