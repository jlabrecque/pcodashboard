class DonationsLoad < ActiveJob::Base
  def perform
    result = %x(bin/rails runner "lib/donations-dbload.rb")
  end
end
