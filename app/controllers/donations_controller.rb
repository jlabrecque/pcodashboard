class DonationsController < ApplicationController
    layout 'admin'

    def index
      @donations = Donation.sorted
    end

    def show
      @donation = Donation.find(params[:id])
    end

    def new
      @donation = Donation.new()
    end

    def create
      @donation = Donation.new(donation_params)
      if @donation.save
        flash[:notice] = "Donation created successfully"
        redirect_to(donations_path)
      else
        render('new')
      end
    end

    def edit
      @donation = Donation.find(params[:id])

    end

    def update
      @donation = Donation.find(params[:id])

      if @donation.update_attributes(donation_params)
        flash[:notice] = "Donation updated successfully"
        redirect_to(donations_path(@donation))
      else
        render('edit')
      end

    end

    def delete
      @donation = Donation.find(params[:id])
    end

    def destroy
      @donation = Donation.find(params[:id])
      @donation.destroy
      flash[:notice] = "Donation for #{@donation.donation_id} deleted successfully"
      redirect_to(donations_path)
    end

    private

    def Donation_params
      params.require(:Donation).permit(
              :donation_id,
              :amount_cents,
              :donation_created_at,
              :donation_updated_at,
              :payment_channel,
              :payment_method,
              :payment_method_sub,
              :designation_id,
              :designation_cents,
              :fund_id
              )
    end
end
