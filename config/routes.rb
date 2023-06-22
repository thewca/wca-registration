# frozen_string_literal: true

Rails.application.routes.draw do
  unless Rails.env.production?
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end

  get '/healthcheck', to: 'healthcheck#index'
  # auth route for testing
  # Uncomment this ones we integrate with the monolith
  # unless Rails.env.production?
  #   get '/jwt', to: 'jwt_dev#index'
  # end
  get '/jwt', to: 'jwt_dev#index'
  get '/api/v1/register', to: 'registration#entry'
  post '/api/v1/register', to: 'registration#create'
  patch '/api/v1/register', to: 'registration#update'
  delete '/api/v1/register', to: 'registration#delete'
  get '/api/v1/registrations', to: 'registration#list'
  get '/api/v1/registrations/admin', to: 'registration#list_admin'
end
