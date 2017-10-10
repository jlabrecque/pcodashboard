ActiveAdmin.register Fund do
  actions :index, :show, :edit, :update
  permit_params :fund_id_pco, :name, :description, :tithe

  menu parent: "Donations"

  index do
    column :fund_id_pco
    column :name
    column :description
    column :tithe
    actions
  end

  filter :fund_id_pco, label: "Fund ID"
  filter :name
  filter :tithe, as: :select

  form do |f|
    f.inputs do
      f.input :fund_id_pco
      f.input :name
      f.input :tithe
      f.actions
    end
    end

end
