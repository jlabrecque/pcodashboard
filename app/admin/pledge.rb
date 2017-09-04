ActiveAdmin.register Pledge do

menu priority: 6, label: "Pledges"
menu parent: "Pledge Mgmt"

active_admin_importable
index do
  selectable_column
  column :campaign
  column :pledge_date
  column "Primary First Name", :fname
  column "Primary Last Name", :lname
  column "Secondary First Name", :fname2
  column "Secondary Last Name", :lname2
  column :periodicity
  actions
end

filter :campaign, as: :select, :collection => Campaign.where(:closed => 0).pluck(:campaign_name, :campaign_id)
filter :fname, label: "Primary First Name"
filter :lname, label: "Primary Last Name"
filter :fname2, label: "Secondary First Name"
filter :lname2, label: "Secondary Last Name"
filter :periodicity, as: :select
end
