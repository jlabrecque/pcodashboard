ActiveAdmin.register_page "Scheduled Jobs Restart" do
  require 'pcocore_api.rb'


  menu priority: 98, label: "Scheduled Jobs Restart"
  menu parent: "Job Mgmt"

content do

        render partial: 'scheduled_job_restart' #, :locals => {:transactions => Transaction.all}
end


end
