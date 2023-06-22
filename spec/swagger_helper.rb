# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1',
      },
      components: {
        schemas: {
          registration: {

            type: :object,
            properties: {
              attendee_id: { type: :string },
              competition_id: { type: :string },
              user_id: { type: :string },
              is_attending: { type: :boolean },
              lane_states: {
                type: :object,
              },
              lanes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    lane_name: { type: :string },
                    lane_state: { type: :string },
                    completed_steps: {
                      type: :array,
                    },
                    lane_details: {
                      type: :object,
                    },
                    payment_reference: { type: :string },
                    payment_amount: { type: :string },
                    transaction_currency: { type: :string },
                    discount_percentage: { type: :string },
                    discount_amount: { type: :string },
                    last_action: { type: :string },
                    last_action_datetime: { type: :string, format: :date_time },
                    last_action_user: { type: :string },
                  },
                  required: [:lane_name, :lane_state, :completed_steps, :lane_details,
                             :payment_reference, :payment_amount, :transaction_currency,
                             :last_action, :last_action_datetime, :last_action_user],
                },
              },
              hide_name_publicly: { type: :boolean },
            },
            required: [:attendee_id, :competition_id, :user_id, :is_attending, :lane_states,
                       :lanes, :hide_name_publicly],
          },
        },
      },
      paths: {},
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'www.example.com',
            },
          },
        },
      ],
    },
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
