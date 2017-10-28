# cronotab.rb — Crono configuration file

$checkinsload = Cron.checkins[0]
$donationsload = Cron.donations[0]
$peopleload = Cron.people[0]

$servicesload = Cron.servicetypes[0]

$mailchimpload = Cron.mailchimplists[0]
$geocodedaily = Cron.geocode[0]


class PeopleLoad < ActiveJob::Base
  def perform
    load $peopleload.script_name
  end
end

class DonationsLoad < ActiveJob::Base
  def perform
    load $donationsload.script_name
  end
end

class CheckinsLoad < ActiveJob::Base
  def perform
    load $checkinsload.script_name
  end
end

class ServicesLoad < ActiveJob::Base
  def perform
    load $servicesload.script_name
  end
end

class MailchimpLoad < ActiveJob::Base
  def perform
    load $mailchimpload.script_name
  end
end

class GeocodeDaily < ActiveJob::Base
  def perform
    load $geocodedaily.script_name
  end
end

if $peopleload.enabled
  Crono.perform(PeopleLoad).every 1.days, at: {hour: $peopleload.hour, min: $peopleload.minute}
end
if $donationsload.enabled
  Crono.perform(DonationsLoad).every 1.days, at: {hour: $donationsload.hour, min: $donationsload.minute}
end
if $checkinsload.enabled
  Crono.perform(CheckinsLoad).every 1.days, at: {hour: $checkinsload.hour, min: $checkinsload.minute}
end
if $servicesload.enabled
  Crono.perform(ServicetypeLoad).every 1.days, at: {hour: $servicesload.hour, min: $servicesload.minute}
end

if $mailchimpload.enabled
  Crono.perform(MailchimplistsLoad).every 1.days, at: {hour: $mailchimpload.hour, min: $mailchimpload.minute}
end
if $geocodedaily.enabled
  Crono.perform(GeocodeDaily).every 1.days, at: {hour: $geocodedaily.hour, min: $geocodedaily.minute}
end
