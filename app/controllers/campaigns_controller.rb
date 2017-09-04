  class CampaignsController < ApplicationController
    #  layout 'admin'
        layout 'application'

      def index
        @campaigns = Campaign.sorted
      end

      def show
        @campaign = Campaign.find(params[:id])
      end

      def new
        @campaign = Campaign.new({:campaign_id => 100, :campaign_name => 'Next'})
      end

      def create
        @campaign = Campaign.new({:campaign_id => 100, :campaign_name => 'Next'})
        if @campaign.save
          flash[:notice] = "Campaign.created successfully"
          redirect_to(campaign_path)
        else
          render('new')
        end
      end

      def edit
        @campaign = Campaign.find(params[:id])

      end

      def update
        @campaign = Campaign.find(params[:id])

        if @campaign.update_attributes(campaign_path)
          flash[:notice] = "Campaign updated successfully"
          redirect_to(campaign_path(@campaign))
        else
          render('edit')
        end

      end

      def delete
        @campaign = Campaign.find(params[:id])
      end

      def destroy
        @campaign = Campaign.find(params[:id])
        @campaign.destroy
        flash[:notice] = "Campaign.#{@campaign.campaign_name} deleted successfully"
        redirect_to(campaign_path)
      end
  end
