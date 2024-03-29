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
        securitySchemes: {
          Bearer: {
            description: '...',
            type: :apiKey,
            name: 'Authorization',
            in: :header,
          },
        },
        schemas: {
          error_response: {
            type: :object,
            properties: {
              error: {
                type: :number,
              },
            },
            required: [:error],
          },
          success_response: {
            type: :object,
            properties: {
              status: {
                type: :string,
              },
              message: {
                type: :string,
              },
            },
            required: [:status, :message],
          },
          registration: {
            type: :object,
            properties: {
              user_id: {
                type: :string,
              },
              competing: {
                type: :object,
                properties: {
                  event_ids: {
                    type: :array,
                    items: {
                      type: :string,
                      format: :EventId,
                    },
                  },
                },
                required: [:event_ids],
              },
            },
            required: [:user_id, :competing],
          },
          registrationAdmin: {
            type: :object,
            properties: {
              user_id: {
                type: :string,
              },
              competing: {
                type: :object,
                properties: {
                  event_ids: {
                    type: :array,
                    items: {
                      type: :string,
                      format: :EventId,
                    },
                  },
                  registered_on: {
                    type: :string,
                  },
                  registration_status: {
                    type: :string,
                  },
                  comment: {
                    type: :string,
                    nullable: true,
                  },
                  admin_comment: {
                    type: :string,
                    nullable: true,
                  },
                },
                required: [:event_ids, :registered_on, :registration_status],
              },
              guests: {
                type: :number,
                nullable: true,
              },
            },
            required: [:user_id, :competing],
          },
          submitRegistrationBody: {
            properties: {
              user_id: {
                type: :string,
              },
              competition_id: {
                type: :string,
              },
              competing: {
                type: :object,
                properties: {
                  event_ids: {
                    type: :array,
                    items: {
                      type: :string,
                      format: :EventId,
                    },
                  },
                  comment: {
                    type: :string,
                  },
                  guests: {
                    type: :number,
                  },
                },
              },
            },
            required: [:user_id, :competition_id, :competing],
          },
          updateRegistrationBody: {
            properties: {
              user_id: {
                type: :string,
              },
              competition_id: {
                type: :string,
              },
              competing: {
                type: :object,
                properties: {
                  event_ids: {
                    type: :array,
                    items: {
                      type: :string,
                      format: :EventId,
                    },
                  },
                  status: {
                    type: :string,
                  },
                  comment: {
                    type: :string,
                  },
                  admin_comment: {
                    type: :string,
                  },
                },
              },
              guests: {
                type: :number,
              },
            },
            required: [:user_id, :competition_id],
          },
        },
      },
      paths: {},
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'registration.worldcubeassociation.org',
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
  config.openapi_format = :yaml
end
