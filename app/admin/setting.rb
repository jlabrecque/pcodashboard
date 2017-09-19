ActiveAdmin.register Setting do

  menu parent: "Site Mgmt"

  permit_params :first_run, :site_name, :site_logo_url, :pcoauthtok, :pcoauthsec, :campus_fd, :mailchimpapikey, :mailchimp_list, :mc_status_fd, :mc_cleanunsubaddress_fd, :mc_cleanunsubdate_fd, :mailgun_api, :mailgun_url, :mailgun_domain, :mailgun_username, :mailgun_pwd, :googlemaps_api, :admin_email
  actions :index, :update, :edit
  action_item :view, only: :index do
    link_to 'Edit Settings', "/admin/settings/1/edit"
  end
  config.filters = false



  index as: :block do |setting|
    div for: setting do
      h2("Sitewide Parameters", :class => "section_title")
      div simple_format  "SiteName: #{setting.site_name}"
      div simple_format  "SiteURL: #{setting.site_url}"
      div simple_format  "SiteLogoURL: #{setting.site_logo_url}"
      div simple_format  "Admin Email Address: #{setting.admin_email}"

      h2("Planning Center Parameters", :class => "section_title")
      div simple_format  "PCO AuthToken: #{setting.pcoauthtok}"
      div simple_format  "PCO AuthSecurity: #{setting.pcoauthsec}"

      h2("Campus Parameters", :class => "section_title")
      div simple_format  "Campus Custom Field Definition: #{setting.campus_fd}"

      h2("Mailchimp API Parameters", :class => "section_title")
      div simple_format  "Mailchimp API Key: #{setting.mailchimpapikey}"
      div simple_format  "Mailchimp Target List: #{setting.mailchimp_list}"

      h2("Mailchimp PCO Field Definitions", :class => "section_title")
      div simple_format  "Mailchimp Custom Field Definitions: #{setting.mc_status_fd}"
      div simple_format  "Mailchimp Custom Field Definitions: #{setting.mc_cleanunsubaddress_fd}"
      div simple_format  "Mailchimp Custom Field Definitions: #{setting.mc_cleanunsubdate_fd}"

      h2("Mailgun Parameters", :class => "section_title")
      div simple_format  "Mailgun API Key: #{setting.mailgun_api}"
      div simple_format  "Mailgun API URL: #{setting.mailgun_url}"
      div simple_format  "Mailgun Domain: #{setting.mailgun_domain}"
      div simple_format  "Mailgun Username: #{setting.mailgun_username}"
      div simple_format  "Mailgun Pwd: #{setting.mailgun_pwd}"

      h2("Google API Parameters", :class => "section_title")
      div simple_format  "Google Geocoder API Key: #{setting.googlemaps_api}"

      h2("Other", :class => "section_title")
      div simple_format  "First Run?: #{setting.first_run}"

      h1 ""
    end
  end
  form do |f|
    tabs do
      tab 'Sitewide' do
        f.inputs 'Sitewide Parameters' do
          f.input :site_name
          f.input :site_logo_url
          f.input :admin_email
          f.input :first_run
        end
      end

      tab 'PCO API' do
        f.inputs 'Planning Center API Parameters' do
          f.input :pcoauthtok
          f.input :pcoauthsec
        end
        para "You will need to visit the to create a Personal Access Token to enter here."
        para "Be sure that the account used to create the access tokens has admin priviledges to allow access to all data."
        text_node link_to("PCO Developer API Page","https://api.planningcenteronline.com/oauth/applications" )
      end

      tab 'PCO FD' do
        f.inputs 'Planning Center Field Definitions' do
          f.input :campus_fd
        end
      end

      tab 'Mailchimp API' do
        f.inputs 'Mailchimp API Parameters' do
          f.input :mailchimpapikey
          f.input :mailchimp_list
        end
      end

      tab 'Mailchimp FD' do
        f.inputs 'Mailchimp PCO Field Definitions' do
          f.input :mc_status_fd
          f.input :mc_cleanunsubaddress_fd
          f.input :mc_cleanunsubdate_fd
        end
      end

      tab 'Mailgun API' do
        f.inputs 'Mailchimp PCO Field Definitions' do
          f.input :mailgun_api
          f.input :mailgun_url
          f.input :mailgun_domain
          f.input :mailgun_username
          f.input :mailgun_pwd
        end
      end

      tab 'Google API' do
        f.inputs 'Mailchimp PCO Field Definitions' do
          f.input :googlemaps_api
        end
      end

    end
    f.actions
  end
end
