Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/healthcheck', to: 'healthcheck#index'
  post '/register', to: 'registration#create'
  patch '/register', to: 'registration#update'
  delete '/register', to: 'registration#delete'
  get '/registrations', to: 'registration#list'
  get '/metrics', to: 'metrics#index'
end
