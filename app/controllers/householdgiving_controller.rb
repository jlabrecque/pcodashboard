class HouseholdGivingController < ApplicationController
  def index
    @householdgiving = HouseholdGiving.where("annavg > ?", 0)

  end

  def show
  end

  def new
  end

  def edit
  end

  def delete
  end
end
