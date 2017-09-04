ActiveAdmin.register_page "Scheduled Job Status" do
  require 'rubygems'

  menu priority: 98, label: "Scheduled Job Status"
  menu parent: "Job Mgmt"

    content do
        render partial: 'scheduled_job_status'
    end
end
