Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config

  begin
      ActiveAdmin.routes(self)
    rescue Exception => e
      puts "ActiveAdmin: #{e.class}: #{e}"
    end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"

  authenticate :admin_user, lambda { |u| u.admin? } do
    mount Crono::Web, at: '/crono'
  end


  resources :reports do
  member do
    get :qreport
  end
  resources :people do
  member do
    get :delete
  end
end
end

end
