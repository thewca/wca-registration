# frozen_string_literal: true

Rails.application.routes.draw do
  get '/healthcheck', to: 'healthcheck#index'
  post '/register', to: 'registration#create'
  patch '/register', to: 'registration#update'
  delete '/register', to: 'registration#delete'
  get '/registrations', to: 'registration#list'
end
