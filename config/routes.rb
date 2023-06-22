# frozen_string_literal: true

Rails.application.routes.draw do
  get '/healthcheck', to: 'healthcheck#index'
  # auth route for testing
  # Uncomment this ones we integrate with the monolith
  # unless Rails.env.production?
  #   get '/jwt', to: 'jwt_dev#index'
  # end
  get '/jwt', to: 'jwt_dev#index'
  post '/api/v1/register', to: 'registration#create'
  patch '/api/v1/register', to: 'registration#update'
  delete '/api/v1/register', to: 'registration#delete'
  get '/api/v1/registrations', to: 'registration#list'
end
