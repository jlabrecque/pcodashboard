class Mailchimplist < ApplicationRecord
  belongs_to :person
  scope :unsubscribed, -> { where(:status => "unsubscribed")}
  scope :cleaned, -> { where(:status => "cleaned")}

end
