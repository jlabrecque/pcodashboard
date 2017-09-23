ActiveAdmin.register AdminUser do
  permit_params :username, :email, :password, :password_confirmation, :admin, :core, :pledge
  menu priority: 99, label: "Users"
  menu parent: "Site Mgmt"

  index do
    selectable_column
    id_column
    column :username
    column :email
    column :admin
    column :core
    column :pledge
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :username
      f.input :email
        f.input :password
        f.input :password_confirmation
      f.input :admin
      f.input :core
      f.input :pledge
    end
    f.actions
  end

end
