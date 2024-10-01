# frozen_string_literal: true

Rails.application.routes.draw do
  unless Rails.env.production?
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'

    get '/test/reset', to: 'test#reset'
  end

  get '/healthcheck', to: 'healthcheck#index'
  post '/api/internal/v1/update_payment', to: 'internal#update_payment_status'
  get '/api/internal/v1/:competition_id/registrations', to: 'internal#list_registrations'
  post '/api/internal/v1/:competition_id/add', to: 'internal#create'
  get '/api/internal/v1/:attendee_id', to: 'internal#show_registration'
  get '/api/internal/v1/users/:user_id/registrations', to: 'internal#registrations_for_user'
  get '/api/v1/register', to: 'registration#show'
  post '/api/v1/register', to: 'registration#create'
  patch '/api/v1/register', to: 'registration#update'
  patch '/api/v1/bulk_update', to: 'registration#bulk_update'
  get '/api/v1/registrations/:competition_id/admin', to: 'registration#list_admin'
  get '/api/v1/registrations/mine', to: 'registration#mine'
  get '/api/v1/registrations/:competition_id', to: 'registration#list'
  get '/api/v1/registrations/:competition_id/admin', to: 'registration#list_admin'
  get '/api/v1/:competition_id/payment', to: 'registration#payment_ticket'
  get '/api/v1/:competition_id/count', to: 'registration#count'
  post '/api/v1/:competition_id/import', to: 'registration#import'
end
