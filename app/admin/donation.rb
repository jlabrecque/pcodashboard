ActiveAdmin.register Donation do
  actions :index, :show

  index do
    selectable_column
    column :id
    column :amount_cents
    column :donation_created_at
    column :payment_method
    column :payment_method_sub
    column :fund_id
    column :pco_id
    actions
  end

  filter :amount_cents, label: "Amount (cents)"
  filter :donation_created_at, label: "Date"
  filter :payment_method, as: :select
  filter :payment_method_sub, as: :select, label: "Submethod"
  filter :fund_id, :as => :select, :collection => Fund.pluck(:name, :fund_id),label: "Fund ID"
  filter :pco_id, as: :select, label: "PCO ID"

end
