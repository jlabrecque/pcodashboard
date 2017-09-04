class Setting < ApplicationRecord
  scope :x, lambda { last}
end
