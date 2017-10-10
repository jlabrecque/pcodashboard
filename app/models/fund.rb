class Fund < ApplicationRecord
  scope :tithe, lambda { where(:tithe => TRUE)}
  has_many :donation
end
