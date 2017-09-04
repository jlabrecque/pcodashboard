#!/bin/bash
# Sets the permissions needed for PCOpledge to operate in separate container,
# with access to PCOcore DB

#need to set PCOCORE_HOME before running
PCOCORE_HOME=/Users/dhockenberry/Sites/pcocore
PCOPLEDGE_HOME=/Users/dhockenberry/Sites/pcopledge

# link database.yml file
cd $PCOPLEDGE_HOME/config
rm $PCOPLEDGE_HOME/config/database.yml
ln -s $PCOCORE_HOME/config/database.yml database.yml

# Create soft links for controller files from PCOcore
cd $PCOPLEDGE_HOME/app/controllers/
ln -s $PCOCORE_HOME/app/controllers/admin_user.rb
ln -s $PCOCORE_HOME/app/controllers/campaigns_controller.rb
ln -s $PCOCORE_HOME/app/controllers/donations_controller.rb
ln -s $PCOCORE_HOME/app/controllers/funds_controller.rb
ln -s $PCOCORE_HOME/app/controllers/people_controller.rb
ln -s $PCOCORE_HOME/app/controllers/pledges_controller.rb

# Create soft links for model files from PCOcore
cd $PCOPLEDGE_HOME/app/models/
ln -s $PCOCORE_HOME/app/models/campaign.rb
ln -s $PCOCORE_HOME/app/models/donation.rb
ln -s $PCOCORE_HOME/app/models/fund.rb
ln -s $PCOCORE_HOME/app/models/person.rb
ln -s $PCOCORE_HOME/app/models/pledge.rb

# Create soft links for db Schema file
cd $PCOPLEDGE_HOME/db
ln -s $PCOCORE_HOME/db/schema.rb schema.rb

cd $PCOPLEDGE_HOME/lib
ln -s $PCOCORE_HOME/lib/calendar_methods.rb calendar_methods.rb
