ActiveAdmin.register Campu, as: "Campus" do

  menu priority: 98, label: "Campus Addresses"
  menu parent: "Site Mgmt"
 permit_params :street, :city, :state, :zip
   actions :index, :update, :edit

index do
  column :campus_id
  column :campus_name
  column :street
  column :city
  column :state
  column :zip
  actions
end

filter :campus_name, as: :select

form do |f|
  f.inputs do
    f.input :street
    f.input :city
    f.input :state
    f.input :zip
  end
  f.actions
end

end
