ActiveAdmin.register Peoplelist, as: "PCO People Lists"  do

  actions :index, :show, :edit, :update
  permit_params :list_id_pco, :name, :description, :focallist

  menu priority: 2, label: "PCO Lists"
  menu parent: "People Views"

  batch_action :invertfocalist do |lists|
    batch_action_collection.find(lists).each do |list|
      if list.focallist
        Peoplelist.update(list.id, :focallist => 0 )
      else
        Peoplelist.update(list.id, :focallist => 1 )
      end
    end
    redirect_to collection_path, alert: "Lists updated"
  end

  index do
    selectable_column
    column :list_id_pco, label: "PCO List ID"
    column :name
    column :description
    column :focallist, label: "Focal List" do |fl|
      if fl.focallist
          div :class => "flyes" do
            fl.focallist
          end
      else
        div :class => "flno" do
          fl.focallist
        end
      end
    end
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
