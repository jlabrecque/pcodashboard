ActiveAdmin.register Person do
  require 'batchmethods.rb'


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

    ## Index Batch Actions
        batch_action :email, form: {
          to: %w[CheckedRecords Yourself],
          subject:  :text,
          content:  :textarea,
          copy:  :checkbox
        } do |ids, inputs|
          response = email_selected(ids,inputs)
          # inputs is a hash of all the form fields you requested
          # redirect_to collection_path, notice: [ids, inputs].to_s
          redirect_to collection_path, notice: response
        end

    index as: CheckinsIndex do
          render :partial => "checkinheader"
          $people = Person.first
          # render partial: 'peopleindex' #, :locals => {:transactions => Transaction.all}
          selectable_column
          column :pco_id do |col|
            link_to(col.pco_id, col.peopleapp_link)
          end
          column "Name", :fullname do |col|
            link_to(col.fullname, admin_person_path(col), :class => 'action show')
          end
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
      render :partial => "donationheader"
      $people = Person.first
      # render partial: 'peopleindex' #, :locals => {:transactions => Transaction.all}
      selectable_column
      column :pco_id do |col|
        link_to(col.pco_id, col.peopleapp_link)
      end
      column "Name", :fullname do |col|
        link_to(col.fullname, admin_person_path(col), :class => 'action show')
      end
      tag_column "#{Person.first.week1}", :week1gift
      tag_column "#{Person.first.week2}", :week2gift
      tag_column "#{Person.first.week3}", :week3gift
      tag_column "#{Person.first.week4}", :week4gift
      tag_column "#{Person.first.week5}", :week5gift
      tag_column "#{Person.first.week6}", :week6gift
      tag_column "#{Person.first.week7}", :week7gift
      tag_column "#{Person.first.week8}", :week8gift
      tag_column "#{Person.first.week9}", :week9gift
      tag_column "#{Person.first.week10}", :week10gift
      tag_column "#{Person.first.week11}", :week11gift
      tag_column "#{Person.first.week12}", :week12gift
      tag_column "#{Person.first.week13}", :week13gift
      tag_column "#{Person.first.week14}", :week14gift
      tag_column "#{Person.first.week15}", :week15gift
      tag_column "#{Person.first.week16}", :week16gift
      tag_column "#{Person.first.week17}", :week17gift
      tag_column "#{Person.first.week18}", :week18gift
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
