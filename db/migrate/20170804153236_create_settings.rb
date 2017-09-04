class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.boolean "first_run"
      t.string  "site_name"
      t.string  "site_url"
      t.string  "site_logo_url"
      t.string "pcoauthtok"
      t.string "pcoauthsec"
      t.string "campus_fd"
      t.string "mailchimpapikey"
      t.string "mailchimp_list"
      t.string "mc_status_fd"
      t.string "mc_cleanunsubaddress_fd"
      t.string "mc_cleanunsubdate_fd"
      t.string "mailgun_api"
      t.string "mailgun_url"
      t.string "mailgun_domain"
      t.string "mailgun_username"
      t.string "mailgun_pwd"
      t.string "googlemaps_api"
      t.string "admin_email"
      t.string "nexmo_url"
      t.string "nexmo_key"
      t.string "nexmo_secret"
      t.integer "pullcount_max"
      t.integer "rate_interval"
      t.integer "exceptionbuffer"
      t.integer "sleepbuffer"
      t.timestamps
    end
    rec1 = Setting.create(
      :first_run       => TRUE,
      :admin_email     =>  "admin@somewhere.org",
      :pullcount_max   => 90,
      :rate_interval   => 20,
      :exceptionbuffer => 10,
      :sleepbuffer     => 10
    )
  end
  def self.down
    drop_table :settings

    end
end
