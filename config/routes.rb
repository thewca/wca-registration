# frozen_string_literal: true

Rails.application.routes.draw do
  unless Rails.env.production?
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end

  get '/healthcheck', to: 'healthcheck#index'
  get '/api/v1/register', to: 'registration#show'
  post '/api/v1/register', to: 'registration#create'
  patch '/api/v1/register', to: 'registration#update'
  get '/api/v1/registrations/:competition_id/admin', to: 'registration#list_admin'
  get '/api/v1/registrations/:competition_id', to: 'registration#list'
  get '/api/v1/:competition_id/payment', to: 'registration#payment_ticket'
end
