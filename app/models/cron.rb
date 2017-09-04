class Cron < ApplicationRecord

  scope :people, lambda { where(:job_name => "PeopleLoad")}
  scope :peoplereload, lambda { where(:job_name => "PeopleReload")}
  scope :checkins, lambda { where(:job_name => "CheckinsLoad")}
  scope :donations, lambda { where(:job_name => "DonationsLoad")}
  scope :servicetypes, lambda { where(:job_name => "ServicetypeLoad")}
  scope :plans, lambda { where(:job_name => "PlansLoad")}
  scope :teammembers, lambda { where(:job_name => "TeammembersLoad")}
  scope :mailchimplists, lambda { where(:job_name => "MailchimplistsLoad")}
  scope :geocode, lambda { where(:job_name => "GeocodeDaily")}

end
