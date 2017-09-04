ActiveAdmin.register_page "FD Checks" do
  require 'pcocore_api.rb'


  menu priority: 98, label: "Field Data List"
  menu parent: "Site Mgmt"

content do
  tabs do
    tab 'PCO Field Data List' do

        render partial: 'fielddata_check' #, :locals => {:transactions => Transaction.all}
    end

  end
end


end
