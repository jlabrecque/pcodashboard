ActiveAdmin.register RsvpEvent, as: "RSVP Events" do

  permit_params :name, :peoplelist_id, :sdate, :stime, :description, :info_url, :status

  menu priority: 6, label: "RSVP Events"
  menu parent: "RSVP"

  index do
    column :name
    column :peoplelist_id
    column :sdate
    column :stime
    column :description
    column :info_url
    column  :status
    actions
  end

  filter :status, as: :select

  form do |f|
    f.inputs do
      f.input :name
      f.input :peoplelist_id,  :as => :select, :collection => Peoplelist.pluck(:name, :id), label: "PCO List"
      f.input :sdate, as: :date_time_picker, label: "Event Date",
        picker_options: {
                           min_date: Date.current,
                           datepicker: true,
                           timepicker: false,
                           format:'m-d-Y'
                         }
     f.input :stime, as: :date_time_picker, label: "Event Time",
       picker_options: {
                          min_date: Date.current,
                          timepicker: true,
                          datepicker: false,
                          format:'h:i a'
                        }
      f.input :description
      f.input :info_url
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :sdate
      row :description
    end
    active_admin_comments
  end
  
end
