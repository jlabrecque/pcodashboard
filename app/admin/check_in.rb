ActiveAdmin.register CheckIn do
  actions :index, :show

  index do
    selectable_column
    column :id
    column :checkin_time
    column :checkin_kind
    column :first_name, label: "First Name"
    column :last_name, label: "Last Name"
    column :pco_id, label: "PCO Id"
    column :event
    column :location
    actions
  end



  filter :checkin_kind, as: :select
  filter :first_name, label: "First Name"
  filter :last_name, label: "Last Name"
  filter :pco_id, label: "PCO Id"
  filter :event, as: :select, :collection => Event.pluck(:event_name, :event_id)
  filter :location, as: :select
  filter :created_at, label: "CheckIn Date"
end
