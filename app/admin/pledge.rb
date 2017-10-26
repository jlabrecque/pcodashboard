ActiveAdmin.register Pledge do

menu priority: 0, label: "Pledges"
menu parent: "Pledge Views", priority: 0

active_admin_importable
index do
  selectable_column
  column :campaign_id
  column :pledge_date
  column "Primary First Name", :fname
  column "Primary Last Name", :lname
  column :periodicity
  number_column :pledge_perperiod, as: :currency, unit: "$", separator: ","
  actions
end

filter :campaign_id, as: :select, :collection => Campaign.where(:closed => 0).pluck(:campaign_name, :campaign_id_pco)
filter :lname, label: "Primary Last Name"
filter :pledge_perperiod
filter :periodicity, as: :select

  form do |f|
    f.inputs do

      f.input :campaign_id, :as => :select, :collection => Campaign.pluck(:campaign_name, :id)
      f.input :pledge_date
      f.input :pco_id, :as => :select, :collection => Person.pluck(:fullname, :pco_id), label: "Name"
      f.input :household_id, :as => :select, :collection => Household.pluck(:household_name, :id), label: "Household"
      f.input :pco_id2, :as => :select, :collection => Person.pluck(:fullname, :pco_id), label: "Name2"
      f.input :initial_gift
      f.input :pledge_perperiod
      f.input :pledge_periods
      f.input :periodicity
      f.input :pledge_start
    end
    f.actions
  end

end
