class Setting < ApplicationRecord
  scope :x, lambda { last}
  serialize :namecheck_words
end
