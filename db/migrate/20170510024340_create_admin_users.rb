class CreateAdminUsers < ActiveRecord::Migration[5.0]
  def self.up
    create_table :admin_users do |t|
      t.string "pco_id"
      t.string "first_name", :limit => 25
      t.string "last_name", :limit => 50
      t.string "email", :limit => 100, :default => '', :null => false
      t.string "username", :limit => 25
      t.string "password_digest"
      t.string "encrypted_password", :null => false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer "sign_in_count", :null => false, :default => 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string "current_sign_in_ip"
      t.string "last_sign_in_ip"
      t.boolean "admin"
      t.boolean "pledge"
      t.boolean "core"
      t.timestamps
    end
    add_index("admin_users", "username")
    add_index("admin_users", "email", unique: true)
    add_index("admin_users", "reset_password_token", unique: true)
    user1 = AdminUser.create(
      :pco_id     =>  "000000",
      :first_name =>  "Super",
      :last_name  =>  "Admin",
      :email      =>  "admin@somewhere.org",
      :username   => "admin",
      :password   => "admin"
    )
  end
  def self.down
    drop_table :admin_users
    end
  end
