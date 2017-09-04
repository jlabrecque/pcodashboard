CREATE DATABASE pcocore_development;
CREATE DATABASE pcocore_test;
CREATE DATABASE pcocore_production;
GRANT ALL PRIVILEGES ON pcocore_development.* TO 'pcocore'@'localhost' IDENTIFIED BY 'pcocore';
GRANT ALL PRIVILEGES ON pcocore_test.* TO 'pcocore'@'localhost' IDENTIFIED BY 'pcocore';
GRANT ALL PRIVILEGES ON pcocore_production.* TO 'pcocore'@'localhost' IDENTIFIED BY 'pcocore';
