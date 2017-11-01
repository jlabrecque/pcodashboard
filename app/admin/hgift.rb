ActiveAdmin.register Hgift do

  menu parent: "Giving Views", label: "Household Giving Report"
  actions :index

    index :title => 'Household Giving' do
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
