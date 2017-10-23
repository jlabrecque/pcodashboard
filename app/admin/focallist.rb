ActiveAdmin.register Focallist, as: "FocalList" do

 permit_params :list_name, :description, :peoplelist_id, :peoplelist_id_pco

index do
  column :list_name
  column :description
  column :peoplelist_id
  column :peoplelist_id_pco
  actions
end

filter :list_name, as: :select, label: "List Name"
filter :peoplelist_id_pco, as: :select, label: "PCO List ID"

form do |f|
  f.inputs do
    f.input :list_name
    f.input :description
    f.input :peoplelist_id
    f.input :peoplelist_id_pco
  end
  f.actions
end

end
