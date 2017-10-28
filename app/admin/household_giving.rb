ActiveAdmin.register HouseholdGiving, as: "Household Giving Report" do
  actions :index, :show
  menu priority: 6, label: "Household Giving Report"
    menu parent: "Giving Views"



      index do
        @householdgiving = HouseholdGiving.where("annavg > ?", 0)
        render partial: 'householdgivingindex'
      end

      controller do
      # This code is evaluated within the controller class
      include ActionView::Helpers::NumberHelper
      end

    filter :last_name
    filter :first_name
    filter :campus, as: :select, label: "Campus"
    filter :family, as: :select, label: "Family"
    filter :annavg, label: "Annual Average Giving"
    filter :lastqtravg, label: "Last Qtr Giving"

end
