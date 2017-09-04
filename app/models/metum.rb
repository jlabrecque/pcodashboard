class Metum < ApplicationRecord
  scope :people, lambda { where(:modeltype => "people")}
  scope :donations, lambda { where(:modeltype => "donations")}
  scope :checkins, lambda { where(:modeltype => "checkins")}
  scope :campaigns, lambda { where(:modeltype => "campaigns")}

end
