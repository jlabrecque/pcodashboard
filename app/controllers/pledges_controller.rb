class PledgesController < ApplicationController
  layout 'application'

  def index
    @pledges = Pledge.sorted
  end

  def show
    @pledge = Pledge.find(params[:id])

  end

  def new
    @pledge = Pledge.new({:pledge_periods => 12})
  end

  def create
    @pledge = Pledge.new(pledge_params)
    if @pledge.save
      flash[:notice] = "Pledge created successfully"
      redirect_to(pledges_path)
    else
      render('new')
    end
  end

  def edit
    @pledge = Pledge.find(params[:id])

  end

  def update
    @pledge = Pledge.find(params[:id])

    if @pledge.update_attributes(pledge_params)
      flash[:notice] = "Pledge updated successfully"
      redirect_to(pledges_path(@pledge))
    else
      render('edit')
    end

  end

  def delete
    @pledge = Pledge.find(params[:id])
  end

  def destroy
    @pledge = Pledge.find(params[:id])
    @pledge.destroy
    flash[:notice] = "Pledge for #{@pledge.pco_id} deleted successfully"
    redirect_to(pledges_path)
  end

  private

  def pledge_params
    params.require(:pledge).permit(:pledge_campaign, :pledge_perperiod, :pledge_periods)
  end
end
