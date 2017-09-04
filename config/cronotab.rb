# cronotab.rb — Crono configuration file

$checkinsload = Cron.checkins[0]
$donationsload = Cron.donations[0]
$peopleload = Cron.people[0]

$servicetypeload = Cron.servicetypes[0]
$plansload = Cron.plans[0]
$teammembersload = Cron.teammembers[0]

$mailchimplistsload = Cron.mailchimplists[0]
$geocodedaily = Cron.geocode[0]


class CheckinsLoad < ActiveJob::Base
  def perform
    load $checkinsload.script_name
  end
end

class DonationsLoad < ActiveJob::Base
  def perform
    load $donationsload.script_name
  end
end

class PeopleLoad < ActiveJob::Base
  def perform
    load $peopleload.script_name
  end
end

class ServicetypeLoad < ActiveJob::Base
  def perform
    load $servicetypeload.script_name
  end
end
class PlansLoad < ActiveJob::Base
  def perform
    load $plansload.script_name
  end
end
class TeammembersLoad < ActiveJob::Base
  def perform
    load $teammembersload.script_name
  end
end

class MailchimplistsLoad < ActiveJob::Base
  def perform
    load $mailchimplistsload.script_name
  end
end
class GeocodeDaily < ActiveJob::Base
  def perform
    load $geocodedaily.script_name
  end
end

if $checkinsload.enabled
  Crono.perform(CheckinsLoad).every 1.days, at: {hour: $checkinsload.hour, min: $checkinsload.minute}
end

if $donationsload.enabled
  Crono.perform(DonationsLoad).every 1.days, at: {hour: $donationsload.hour, min: $donationsload.minute}
end

if $peopleload.enabled
  Crono.perform(PeopleLoad).every 1.days, at: {hour: $peopleload.hour, min: $peopleload.minute}
end

if $servicetypeload.enabled
  Crono.perform(ServicetypeLoad).every 1.days, at: {hour: $servicetypeload.hour, min: $servicetypeload.minute}
end
if $plansload.enabled
  Crono.perform(PlansLoad).every 1.days, at: {hour: $plansload.hour, min: $plansload.minute}
end
if $teammembersload.enabled
  Crono.perform(TeammembersLoad).every 1.days, at: {hour: $teammembersload.hour, min: $teammembersload.minute}
end

if $mailchimplistsload.enabled
  Crono.perform(MailchimplistsLoad).every 1.days, at: {hour: $mailchimplistsload.hour, min: $mailchimplistsload.minute}
end
if $geocodedaily.enabled
  Crono.perform(GeocodeDaily).every 1.days, at: {hour: $geocodedaily.hour, min: $geocodedaily.minute}
end
