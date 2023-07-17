# frozen_string_literal: true

require 'swagger_helper'
require_relative '../../support/helpers/registration_spec_helper'

RSpec.shared_context 'test_registration_data' do
  include Helpers::RegistrationHelper

  let(:basic_registration) { { user_id: '158817' } }
  let(:other_registration) { { user_id: '158816' } }
end

RSpec.shared_examples 'payload test' do |payload|
  before do
    puts "Payload: #{payload}"
  end

  let(:registration) { payload }
  let(:'Authorization') { @jwt_token } # Hardcoding the JWT token will lead to an impersonation error on the 2nd test if we send it the correct payload
  run_test!
end

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper
  include_context 'basic_auth_token'
  include_context 'test_registration_data'

  path '/api/v1/register' do
    post 'Add an attendee registration' do
      consumes 'application/json'
      parameter name: 'Authorization', in: :header, type: :string
      parameter name: :registration, in: :body,
                schema: { '$ref' => '#/components/schemas/registration' }, required: true

      before do
        puts "Basic registration: #{basic_registration}"
      end
      response '202', 'various optional fields' do
        it_behaves_like 'payload test' do
          let(:passed_payload) { basic_registration }
        end
        it_behaves_like 'payload test' do
          let(:another_passed_payload) { other_registration }
        end
      end
    end
  end
end
