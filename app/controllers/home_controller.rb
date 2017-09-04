class HomeController < ApplicationController

  def index

    @people = Person.all
    @donations = Donation.all
    @checkins = CheckIn.all
  end

end
