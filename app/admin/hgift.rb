ActiveAdmin.register Hgift do
  menu label: "Household Giving Report"
  actions :index

    menu priority: 6
    menu parent: "Giving Views"


    index do
      @hgifts = Hgift.where("annavg > ?", 0)
      render partial: 'hgiftsindex'
    end

    filter :last_name
    filter :first_name
    filter :campus, as: :select, label: "Campus"
    filter :family, as: :select, label: "Family"
    filter :annavg, label: "Annual Average Giving"
    filter :lastqtravg, label: "Last Qtr Giving"

end
