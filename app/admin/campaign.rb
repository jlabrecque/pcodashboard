ActiveAdmin.register Campaign do


 permit_params :campaign_id, :campaign_name, :fund_id_pco, :start_date, :end_date, :closed, :closeddate
 menu priority: 3, label: "Campaigns"
 menu parent: "Pledge Views"

index do
  selectable_column
  column :campaign_id
  column :campaign_name
  column :fund_id_pco
  column :start_date
  column :end_date
  column :closed
  column :closeddate
  actions
end

filter :campaign_name, as: :select
filter :fund_id_pco, as: :select, :collection => Fund.pluck(:name, :fund_id_pco)
filter :closed, as: :select

form do |f|
  f.inputs do
    if f.object.new_record?
        cid = Campaign.last
        f.object.campaign_id = (cid["campaign_id"].to_i) + 1
        f.input :campaign_id
    end
    f.input :campaign_name
    f.input :fund_id,  :as => :select, :collection => Fund.pluck(:name, :fund_id)
    f.input :start_date, as: :datepicker,
                          datepicker_options: {
                            min_date: "2016-1-1",
                            max_date: "+5Y"
                          }
    f.input :end_date, as: :datepicker,
                          datepicker_options: {
                            min_date: "2016-1-1",
                            max_date: "+5Y"
                          }
    f.input :closed
    f.input :closeddate, as: :datepicker
  end
  f.actions
end

end
