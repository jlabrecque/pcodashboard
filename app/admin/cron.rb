ActiveAdmin.register Cron, as: "Scheduled Jobs" do

  permit_params :parameters, :description, :dow, :recurring, :hour, :minute, :enabled
  actions :index, :update, :edit

  menu priority: 6, label: "Scheduled Jobs"
  menu parent: "Job Mgmt"

  index do
    column :job_name
    column :script_name
    column :parameters
    column :description
    column :dow, label: "Day of Week"
    column :recurring
    column :hour
    column :minute
    column :enabled, label: "Enabled?"
    actions
  end

  filter :job_name, as: :select
  filter :recurring, label: "Recurring?"
  filter :enabled, label: "Enabled?"


  form do |f|
    f.inputs do
      f.input :parameters
      f.input :description
      f.input :dow, as: :select, collection: (["Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"])
      f.input :recurring, as: :select, collection: (["Daily", "Weekly", "Monthly"])
      f.input :hour
      f.input :minute
      f.input :enabled
      f.actions
    end
  end


end
