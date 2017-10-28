class Cron < ApplicationRecord

  scope :people, lambda { where(:job_name => "PeopleLoad")}
  scope :peoplereload, lambda { where(:job_name => "PeopleReload")}
  scope :checkins, lambda { where(:job_name => "CheckinsLoad")}
  scope :donations, lambda { where(:job_name => "DonationsLoad")}
  scope :services, lambda { where(:job_name => "ServicesLoad")}
  scope :mailchimp, lambda { where(:job_name => "MailchimpLoad")}
  scope :geocode, lambda { where(:job_name => "GeocodeDaily")}

end
