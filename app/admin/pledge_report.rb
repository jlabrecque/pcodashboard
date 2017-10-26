ActiveAdmin.register PledgeReport do


  menu priority: 3, label: "Reports"
  menu parent: "Pledge Views"
  actions :index, :new, :destroy, :create
  permit_params :quarter, :year, :reportname, :filename, :id, :campaign_id, :valfilename

  index do
    column :quarter
    column :year
    column :reportname do |c|
          link_to "#{c.reportname}", "http://#{Setting.first.site_url}/reports/#{c.filename}"
    end
    column :validation do |c|
          link_to "#{c.reportname}_validation", "http://#{Setting.first.site_url}/reports/#{c.valfilename}"
    end
    column :created_at
    actions
  end

  filter :quarter, as: :select
  filter :year, as: :select
  filter :campaign_id, as: :select, :collection => Campaign.pluck(:campaign_name, :id)
  filter :reportname
  filter :created_at

  form do |f|
    f.inputs do
      f.input :quarter, :as => :select, :collection => ["Q1","Q2","Q3","Q4"]
      f.input :year, :as => :select, :collection => ['2016','2017','2018','2019','2020','2021','2022','2023','2024']
      f.input :campaign_id, as: :select, :collection => Campaign.pluck(:campaign_name, :id)
      f.input :reportname
      f.actions
    end
    end
    controller do
      def create
        report = params[:pledge_report]
        q = report["quarter"]
        y = report["year"]
        c = report["campaign_id"]
        fn,vn = pledge_report(q,y,c)
        report["filename"] = fn
        report["valfilename"] = vn
        create! do |succes, failure|
        end
      end
    end
end
