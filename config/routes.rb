Rails.application.routes.draw do
  get '/healthcheck', to: 'healthcheck#index'
  post '/register', to: 'registration#create'
  get '/registrations', to: 'registration#list'
end
