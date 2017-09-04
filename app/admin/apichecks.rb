ActiveAdmin.register_page "API Checks" do
  require 'pcocore_api.rb'


  menu priority: 98, label: "API Checks"
  menu parent: "Site Mgmt"

content do
  tabs do
    tab 'PCO API Check' do
        render partial: 'api_check' #, :locals => {:transactions => Transaction.all}
    end
    tab 'Mailchimp API Check' do

        render partial: 'mailchimp_check' #, :locals => {:transactions => Transaction.all}
    end
    tab 'Mailgun API Check' do

        render partial: 'mailgun_check' #, :locals => {:transactions => Transaction.all}
    end
  end
end


end
