class PeopleLoad < ActiveJob::Base
  def perform
      result = %x(bin/rails runner "lib/people-dbload.rb")
  end
end
