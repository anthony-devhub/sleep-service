Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  mount BaseApi => "/"
  get "/swagger", to: "swagger#index"
end
