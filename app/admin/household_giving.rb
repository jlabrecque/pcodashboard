ActiveAdmin.register HouseholdGiving, as: "Household Giving Report" do
  actions :index, :show
  menu priority: 6, label: "Household Giving Report"
    menu parent: "Giving Views"

    index do
      column :last_name, label: "Last Name"
      column :first_name, label: "First Name"
      column :campus, label: "Campus"
      column :family, label: "Family"
      number_column :annavg, as: :currency, unit: "$", label: "Annual Average Giving"
      number_column :lastqtravg, as: :currency, unit: "$", label: "Last Qtr Giving"
      actions
    end

    filter :last_name
    filter :first_name
    filter :campus, as: :select, label: "Campus"
    filter :family, as: :select, label: "Family"
    filter :annavg, label: "Annual Average Giving"
    filter :lastqtravg, label: "Last Qtr Giving"
end
