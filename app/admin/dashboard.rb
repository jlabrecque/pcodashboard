ActiveAdmin.register_page "Dashboard" do
  require 'rubygems'
  require 'google_chart'
  require 'pcopledge_methods.rb'
  require 'google_visualr'
  require 'calendar_methods.rb'

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }
    content do
        render partial: 'dashboard' #, :locals => {:transactions => Transaction.all}
    end
end
