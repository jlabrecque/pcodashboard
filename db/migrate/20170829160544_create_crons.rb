class CreateCrons < ActiveRecord::Migration[5.0]
  def self.up
    create_table :crons do |t|
    t.string  "job_name"
    t.string  "script_name"
    t.string  "parameters"
    t.string  "description"
    t.string  "dow"
    t.string  "recurring"
    t.integer "hour"
    t.integer "minute"
    t.boolean "enabled"
    t.timestamps
  end
  prime = Cron.create(:job_name => "PeopleLoad", :script_name => "lib/people-dbload.rb", :parameters => "", :description => "Nightly incremently People dB sync",:dow => "", :recurring => "Daily",:hour => 0,:minute => 00,:enabled => FALSE)
  prime = Cron.create(:job_name => "PeopleReload", :script_name => "lib/people-dbload.rb", :parameters => "update", :description => "Weekly full People dB sync",:dow => "Sun", :recurring => "Weekly",:hour => 22,:minute => 00,:enabled => FALSE)
  prime = Cron.create(:job_name => "DonationsLoad", :script_name => "lib/donations-dbload.rb", :parameters => "", :description => "Nightly incremently Donations dB sync",:dow => "", :recurring => "Daily",:hour => 1,:minute => 00,:enabled => FALSE)
  prime = Cron.create(:job_name => "CheckinsLoad", :script_name => "lib/checkins-dbload.rb", :parameters => "", :description => "Nightly incremently Checkins dB sync",:dow => "", :recurring => "Daily",:hour => 2,:minute => 00,:enabled => FALSE)
  prime = Cron.create(:job_name => "ServicetypeLoad", :script_name => "lib/servicetypes-dbload.rb", :parameters => "", :description => "Nightly incremently ServiceType dB sync",:dow => "", :recurring => "Daily",:hour => 3,:minute => 00,:enabled => FALSE)
  prime = Cron.create(:job_name => "PlansLoad", :script_name => "lib/plans-dbload.rb", :parameters => "", :description => "Nightly incremently Plans dB sync",:dow => "", :recurring => "Daily",:hour => 3,:minute => 15,:enabled => FALSE)
  prime = Cron.create(:job_name => "TeammembersLoad", :script_name => "lib/teammember-dbload.rb", :parameters => "", :description => "Nightly incremently TeamMembers dB sync",:dow => "", :recurring => "Daily",:hour => 3,:minute => 30,:enabled => FALSE)
  prime = Cron.create(:job_name => "MailchimplistsLoad", :script_name => "lib/mailchimplist-dbload.rb", :parameters => "", :description => "Nightly Mailchimp List sync",:dow => "", :recurring => "Daily",:hour => 5,:minute => 00,:enabled => FALSE)
  prime = Cron.create(:job_name => "GeocodeDaily", :script_name => "lib/geocode-dbload.rb", :parameters => "", :description => "Nightly Geocode pass -- split alphabetically",:dow => "", :recurring => "Daily",:hour => 6,:minute => 00,:enabled => FALSE)

end
def self.down
  drop_table :crons
  end
end
