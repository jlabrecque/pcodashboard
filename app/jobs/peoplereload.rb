class PeopleReload< ActiveJob::Base


  def perform
    result = %x(bin/rails runner "lib/people-dbload.rb" update)
  end
end
