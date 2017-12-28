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
      $people = Person.first
      # render partial: 'peopleindex' #, :locals => {:transactions => Transaction.all}
      selectable_column
      column :pco_id
      column "Name", :fullname
      tag_column "#{Person.first.week1}", :week1checkin
      tag_column "#{Person.first.week2}", :week2checkin
      tag_column "#{Person.first.week3}", :week3checkin
      tag_column "#{Person.first.week4}", :week4checkin
      tag_column "#{Person.first.week5}", :week5checkin
      tag_column "#{Person.first.week6}", :week6checkin
      tag_column "#{Person.first.week7}", :week7checkin
      tag_column "#{Person.first.week8}", :week8checkin
      tag_column "#{Person.first.week9}", :week9checkin
      tag_column "#{Person.first.week10}", :week10checkin
      tag_column "#{Person.first.week11}", :week11checkin
      tag_column "#{Person.first.week12}", :week12checkin
      tag_column "#{Person.first.week13}", :week13checkin
      tag_column "#{Person.first.week14}", :week14checkin
      tag_column "#{Person.first.week15}", :week15checkin
      tag_column "#{Person.first.week16}", :week16checkin
      tag_column "#{Person.first.week17}", :week17checkin
      tag_column "#{Person.first.week18}", :week18checkin
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
