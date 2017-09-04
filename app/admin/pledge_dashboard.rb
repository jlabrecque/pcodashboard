ActiveAdmin.register_page "Pledge Dashboard" do
  require 'rubygems'
  require 'google_chart'
  require 'pcopledge_methods.rb'
  require 'google_visualr'

menu parent: "Pledge Mgmt"

    content do
        render partial: 'pledgedashboard' #, :locals => {:transactions => Transaction.all}
    end
end
