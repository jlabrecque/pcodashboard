ActiveAdmin.register Person do
  actions :index, :show
  action_item :view, only: :show do
    link_to 'Back to Index', "/admin/people"
  end
  config.per_page = [50, 100, 250]

#    action_item :view_site do
#      link_to "View Donation Grid", "/"
#    end

menu priority: 3, label: "People"
  menu parent: "People Views", priority: 1

    class CheckinsIndex < ActiveAdmin::Views::IndexAsTable
        def self.index_name
          "checkins_location"
        end
      end

      class DonationsIndex < ActiveAdmin::Views::IndexAsTable
          def self.index_name
            "donations_location"
          end
        end

    def person_params
      params.require(:person).permit(:pco_id, :first_name, :last_name, :email)
    end

    controller do
    # This code is evaluated within the controller class
    end

    index as: CheckinsIndex do
      @people = Person.where(:people_status => "active").sorted
      render partial: 'peopleindex' #, :locals => {:transactions => Transaction.all}
    end

    index as: DonationsIndex do
      @people = Person.where(:people_status => "active").sorted
      render partial: 'donationindex' #, :locals => {:transactions => Transaction.all}
    end

    show title: :fullname do
      @person = Person.find(params[:id])
      @checks = CheckIn.where(:checkin_person =>@person.pco_id)
      @donations = Donation.where(:pco_id => @person.pco_id)

      render partial: 'peopleshow' #, :locals => {:transactions => Transaction.all}
    end

    filter :campus, as: :select
    filter :first_name, label: "Primary First Name"
    filter :last_name, label: "Primary Last Name"
    filter :lists, as: :select, collection: Proc.new { Peoplelist.where(:focallist => TRUE).pluck(:name, :id) }, label: "PCO List"

end
