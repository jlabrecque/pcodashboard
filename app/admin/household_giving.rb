ActiveAdmin.register HouseholdGiving, as: "Household Giving Report" do
  actions :index, :show
  menu priority: 6, label: "Household Giving Report"
    menu parent: "Giving Views"


    class HouseholdGivingIndex < ActiveAdmin::Views::IndexAsTable
        def self.index_name
          "householdgiving_location"
        end
      end

      def household_giving_params
        params.require(:householdgiving).permit(:pco_id, :first_name, :last_name, :campus, :family, :annavg, :lastqrtavg)
      end

      controller do
      # This code is evaluated within the controller class
      end

      index as: HouseholdGivingIndex do
        @householdgiving = HouseholdGiving.where("annavg > ?", 0)
        render partial: 'householdgivingindex' #, :locals => {:transactions => Transaction.all}
      end


    filter :last_name
    filter :first_name
    filter :campus, as: :select, label: "Campus"
    filter :family, as: :select, label: "Family"
    filter :annavg, label: "Annual Average Giving"
    filter :lastqtravg, label: "Last Qtr Giving"
end
