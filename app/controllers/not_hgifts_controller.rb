class NotHgiftsController < ApplicationController
  def index
    @giving = Hgifts.where("annavg > ?", 0)
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
