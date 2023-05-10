Rails.application.routes.draw do
  get '/healthcheck', to: 'healthcheck#index'
end
