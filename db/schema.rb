# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170829160544) do

  create_table "active_admin_comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "namespace"
    t.text     "body",          limit: 65535
    t.string   "resource_type"
    t.integer  "resource_id"
    t.string   "author_type"
    t.integer  "author_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree
  end

  create_table "admin_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "pco_id"
    t.string   "first_name",             limit: 25
    t.string   "last_name",              limit: 50
    t.string   "email",                  limit: 100, default: "", null: false
    t.string   "username",               limit: 25
    t.string   "password_digest"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "encrypted_password",                              null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "admin"
    t.boolean  "pledge"
    t.boolean  "core"
    t.index ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree
    t.index ["username"], name: "index_admin_users_on_username", using: :btree
  end

  create_table "campaign_meta", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "campaign_id"
    t.text     "campaign_name",   limit: 65535
    t.float    "totalpledged",    limit: 24
    t.float    "totalprogress",   limit: 24
    t.float    "percentprogress", limit: 24
    t.integer  "num_pledges"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "campaigns", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "campaign_id"
    t.string   "campaign_name"
    t.string   "start_date"
    t.string   "end_date"
    t.string   "fund_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "closed",                    default: false, null: false
    t.datetime "closeddate"
    t.integer  "num_pledges",               default: 0
    t.integer  "num_donations",             default: 0
    t.float    "totalcommitted", limit: 24, default: 0.0
    t.float    "qtrcommited",    limit: 24, default: 0.0
    t.float    "avgpledge",      limit: 24, default: 0.0
    t.float    "totalprogress",  limit: 24, default: 0.0
    t.float    "qtrprogress",    limit: 24, default: 0.0
  end

  create_table "campus", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "campus_id"
    t.string   "campus_name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
  end

  create_table "check_ins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "checkin_id"
    t.string   "checkin_time"
    t.string   "checkin_kind"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "pco_id"
    t.string   "event"
    t.string   "location"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "person_id"
    t.index ["pco_id"], name: "index_check_ins_on_pco_id", using: :btree
  end

  create_table "crono_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "job_id",                               null: false
    t.text     "log",               limit: 4294967295
    t.datetime "last_performed_at"
    t.boolean  "healthy"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["job_id"], name: "index_crono_jobs_on_job_id", unique: true, using: :btree
  end

  create_table "crons", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "job_name"
    t.string   "script_name"
    t.string   "parameters"
    t.string   "description"
    t.string   "dow"
    t.string   "recurring"
    t.integer  "hour"
    t.integer  "minute"
    t.boolean  "enabled"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "donations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "donation_id"
    t.decimal  "amount_cents",        precision: 10
    t.string   "donation_created_at"
    t.string   "donation_updated_at"
    t.string   "payment_channel"
    t.string   "payment_method"
    t.string   "payment_method_sub"
    t.string   "designation_id"
    t.decimal  "designation_cents",   precision: 10
    t.string   "fund_id"
    t.string   "pco_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "person_id"
  end

  create_table "events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "event_id"
    t.string   "event_name"
    t.string   "event_updated_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "funds", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "fund_id"
    t.string   "name"
    t.string   "description"
    t.string   "fund_updated_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "geo_maps", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "pco_id"
    t.string   "campus_id"
    t.string   "full_address"
    t.float    "latitude",     limit: 24
    t.float    "longitude",    limit: 24
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "person_id"
    t.index ["person_id"], name: "index_geo_maps_on_person_id", using: :btree
  end

  create_table "group_attendances", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "group_id"
    t.integer  "person_id"
    t.string   "attend_date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["group_id", "person_id"], name: "index_group_attendances_on_group_id_and_person_id", using: :btree
  end

  create_table "group_memberships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "group_id"
    t.integer  "person_id"
    t.boolean  "leader"
    t.string   "started"
    t.string   "ended"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "person_id"], name: "index_group_memberships_on_group_id_and_person_id", using: :btree
  end

  create_table "groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "pco_group_id"
    t.string   "description"
    t.string   "category"
    t.string   "start"
    t.string   "end"
    t.boolean  "open"
    t.string   "group_url"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "location_id"
    t.string   "location_name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "mailchimplists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "email_type"
    t.string   "lname"
    t.string   "fname"
    t.float    "open_rate",     limit: 24
    t.float    "click_rate",    limit: 24
    t.string   "status"
    t.string   "email_client"
    t.string   "timezone"
    t.string   "country"
    t.float    "longitude",     limit: 24
    t.float    "latitude",      limit: 24
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "email_address"
    t.string   "unique_id"
    t.string   "list_id"
    t.datetime "info_changed"
    t.integer  "person_id"
  end

  create_table "mccampaigns", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "mailchimp_campaign_id"
    t.integer  "mccampaignsend_id"
    t.integer  "web_id"
    t.string   "campaign_type"
    t.string   "create_time"
    t.string   "send_time"
    t.string   "long_archive_url"
    t.string   "status"
    t.integer  "emails_sent"
    t.string   "subject_line"
    t.string   "title"
    t.string   "from"
    t.string   "reply_to"
    t.integer  "opens"
    t.integer  "unique_opens"
    t.float    "open_rate",             limit: 24
    t.integer  "clicks"
    t.float    "click_rate",            limit: 24
    t.integer  "subscriber_clicks"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["mccampaignsend_id"], name: "index_mccampaigns_on_mccampaignsend_id", using: :btree
  end

  create_table "mccampaignsends", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "person_id"
    t.integer  "mccampaign_id"
    t.string   "mailchimp_email_id"
    t.string   "mailchimp_campaign_id"
    t.string   "mailchimp_list_id"
    t.string   "email_address"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "status"
    t.integer  "open_count"
    t.string   "last_open"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["mccampaign_id"], name: "index_mccampaignsends_on_mccampaign_id", using: :btree
    t.index ["person_id"], name: "index_mccampaignsends_on_person_id", using: :btree
  end

  create_table "meta", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "modeltype"
    t.date     "last_import"
    t.string   "last_id_imported"
    t.integer  "total_processed"
    t.integer  "total_created"
    t.integer  "total_updated"
    t.integer  "last_offset"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "people", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "pco_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.string   "nickname"
    t.string   "email"
    t.string   "hphone"
    t.string   "mphone"
    t.string   "carrier"
    t.string   "gender"
    t.string   "birthdate"
    t.string   "campus"
    t.string   "membership"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "peopleapp_link"
    t.string   "people_thumbnail"
    t.string   "people_notes"
    t.string   "people_status"
    t.string   "pco_created_at"
    t.string   "pco_updated_at"
    t.string   "first_attended"
    t.string   "last_attended"
    t.string   "first_donation"
    t.string   "last_donation"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "fullname"
    t.string   "email_array"
  end

  create_table "plans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "plid"
    t.string   "stid"
    t.string   "pldates"
    t.string   "pl_sort_date"
    t.string   "pl_updated_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "service_type_id"
    t.index ["service_type_id"], name: "index_plans_on_service_type_id", using: :btree
  end

  create_table "pledge_reports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "quarter"
    t.string   "year"
    t.integer  "campaign_id"
    t.string   "reportname"
    t.string   "filename"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "pledges", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "campaign"
    t.string   "pledge_date"
    t.string   "pco_id"
    t.string   "fname"
    t.string   "lname"
    t.string   "pco_id2"
    t.string   "fname2"
    t.string   "lname2"
    t.string   "family_id"
    t.decimal  "initial_gift",     precision: 10
    t.decimal  "pledge_perperiod", precision: 10
    t.integer  "pledge_periods"
    t.string   "periodicity"
    t.string   "pledge_start"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "service_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "stid"
    t.string   "st_name"
    t.string   "st_updated_at"
    t.string   "st_freq"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.boolean  "first_run"
    t.string   "site_name"
    t.string   "site_url"
    t.string   "site_logo_url"
    t.string   "pcoauthtok"
    t.string   "pcoauthsec"
    t.string   "campus_fd"
    t.string   "mailchimpapikey"
    t.string   "mailchimp_list"
    t.string   "mc_status_fd",            limit: 25
    t.string   "mc_cleanunsubaddress_fd", limit: 25
    t.string   "mc_cleanunsubdate_fd",    limit: 25
    t.string   "mailgun_api"
    t.string   "mailgun_url"
    t.string   "mailgun_domain"
    t.string   "mailgun_username"
    t.string   "mailgun_pwd"
    t.string   "googlemaps_api"
    t.string   "admin_email"
    t.string   "nexmo_url",               limit: 50
    t.string   "nexmo_key",               limit: 50
    t.string   "nexmo_secret",            limit: 50
    t.integer  "pullcount_max"
    t.integer  "rate_interval"
    t.integer  "exceptionbuffer"
    t.integer  "sleepbuffer"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "teammembers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "plan_id"
    t.string   "plid"
    t.string   "plan_dates"
    t.string   "plan_sort_date"
    t.string   "tmid"
    t.string   "pco_id"
    t.integer  "person_id"
    t.string   "name"
    t.string   "position"
    t.string   "status"
    t.string   "decline_reason"
    t.string   "planperson"
    t.string   "plan_updated_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["person_id"], name: "index_teammembers_on_person_id", using: :btree
    t.index ["plan_id"], name: "index_teammembers_on_plan_id", using: :btree
  end

  create_table "visits", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "country"
    t.datetime "visited_at"
    t.decimal  "load_time",  precision: 10
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

end
