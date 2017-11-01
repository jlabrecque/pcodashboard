ActiveAdmin.register Peoplelist, as: "PCO People Lists"  do

  actions :index, :show, :edit, :update
  permit_params :list_id_pco, :name, :description, :focallist

  menu priority: 2, label: "PCO Lists"
  menu parent: "People Views"

  index do
    column :list_id_pco, label: "PCO List ID"
    column :name
    column :description
    column :focallist, label: "Focal List"
    actions
  end

  filter :name
  filter :focallist, as: :select, label: "Focal List"

  form do |f|
    f.inputs do
      f.input :focallist, label: "Focal List"
    end
    f.actions
    end

end
