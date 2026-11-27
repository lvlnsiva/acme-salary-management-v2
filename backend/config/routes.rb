
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :countries, only: :index
      resources :departments, only: :index
      resources :employees do
        resources :salaries, only: [:index, :create]
      end

      get "insights", to: "insights#index"
    end
  end
end
