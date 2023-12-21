# frozen_string_literal: true

Rails.application.routes.draw do
  unless Rails.env.production?
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'

    get '/test/jwt/:user_id', to: 'test#token'
    get '/test/reset', to: 'test#reset'
  end

  get '/healthcheck', to: 'healthcheck#index'
  post '/api/internal/v1/update_payment', to: 'internal#update_payment_status'
  get '/api/v1/register', to: 'registration#show'
  post '/api/v1/register', to: 'registration#create'
  patch '/api/v1/register', to: 'registration#update'
  patch '/api/v1/bulk_update', to: 'registration#bulk_update'
  get '/api/v1/registrations/:competition_id/admin', to: 'registration#list_admin'
  get '/api/v1/registrations/:competition_id', to: 'registration#list'
  get '/api/v1/:competition_id/payment', to: 'registration#payment_ticket'
  post '/api/v1/:competition_id/import', to: 'registration#import'
end
