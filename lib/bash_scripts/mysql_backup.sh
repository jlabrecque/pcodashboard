mysql_user=XXX
mysql_pass=YYYY
backup_dir=/backup

# Perform backup of the pcocore_dev database, capying to dated backup file
now=$(date "+%F_%T")
/usr/bin/mysqldump -u$mysql_user -p$mysql_pass pcocore_development > $backup_dir/mysql_backup_$now.sql
/usr/bin/mysqldump -u$mysql_user -p$mysql_pass pcocore_development check_ins > $backup_dir/mysql_backup_checkins_$now.sql
/usr/bin/mysqldump -u$mysql_user -p$mysql_pass pcocore_development checkin_meta> $backup_dir/mysql_backup_checkinsmeta_$now.sql
/usr/bin/mysqldump -u$mysql_user -p$mysql_pass pcocore_development donations > $backup_dir/mysql_backup_donations_$now.sql
/usr/bin/mysqldump -u$mysql_user -p$mysql_pass pcocore_development donations_meta > $backup_dir/mysql_backup_donationsmeta_$now.sql
/usr/bin/mysqldump -u$mysql_user -p$mysql_pass pcocore_development people > $backup_dir/mysql_backup_people_$now.sql
/usr/bin/mysqldump -u$mysql_user -p$mysql_pass pcocore_development peoplemeta > $backup_dir/mysql_backup_peoplemeta_$now.sql


#for maintenance, also check and delete any backup files older than 30 days
find /backup -mtime +30 -type f -delete

# Script to be run via cron on the pcocore host
# example, using crontab -e :
# 0 0 * * 5 /usr/local/bin/mysql_backup.sh
# runs the command Fridays at Midnight
