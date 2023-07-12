# frozen_string_literal: true

require 'swagger_helper'
require_relative '../../support/helpers/registration_spec_helper'

# end
#  

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  def fetch_jwt_token(user_id='15073')
    iat = Time.now.to_i
    jti_raw = [JwtOptions.secret, iat].join(':').to_s
    jti = Digest::MD5.hexdigest(jti_raw)
    payload = { data: { user_id: user_id }, exp: Time.now.to_i + JwtOptions.expiry, sub: user_id, iat: iat, jti: jti }
    token = JWT.encode payload, JwtOptions.secret, JwtOptions.algorithm
    "Bearer #{token}"
  end

  path '/api/v1/register' do
    post 'Add an attendee registration' do
      parameter name: :registration, in: :body,
                schema: { '$ref' => '#/components/schemas/registration' }, required: true
      parameter name: 'Authorization', in: :header, type: :string

      # let!(:jwt_token) { fetch_jwt_token }
      # header 'Authorization', "Bearer #{jwt_token}"

      # TODO: Figure out how to validate the data written to the database
      context 'success registration posts' do
        include_context 'basic_auth_token'
        include_context 'registration_data'


        response '202', 'only required fields included' do
          # before do
          #   @jwt_token = fetch_jwt_token()
          #   puts "Token: #{@jwt_token}"
          # end
          # include_context 'registration_data' # NOTE: Commented out because I'm only partially sure include_context in a shared context works
          let(:registration) { required_fields_only }
          let(:'Authorization') { @jwt_token }
          # let(:'Authorization') { 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJkYXRhIjp7InVzZXJfaWQiOiIxNTA3MyJ9LCJleHAiOiIxNjg5MTU0NTY4Iiwic3ViIjoiMTUwNzMiLCJpYXQiOjE2ODkxNTI3NjgsImp0aSI6ImFmNzk3NGU0NjliMzRiM2Y2NjQ5MzYwZWM1ZWQxOTUzIn0.eS-ujg1L9dtO
                                    # Dp_jYd-bIzLo9d1orZ8ol0DXinbD7vk' }

          run_test! do |request|
            puts request
          end
        end

        response '202', 'various optional fields' do
          # include_context 'registration_data' NOTE: Commented out because I'm only partially sure include_context in a shared context works
          it_behaves_like 'optional field tests', @with_is_attending
          it_behaves_like 'optional field tests', @with_hide_name_publicly
          it_behaves_like 'optional field tests', @with_all_optional_fields
        end
      end

      context 'fail: request validation fails' do
        include_context 'registration_data'

        response '400', 'bad request - required fields not found' do
          it_behaves_like 'payload error tests', @missing_reg_fields
          it_behaves_like 'payload error tests', @empty_json
          it_behaves_like 'payload error tests', @missing_lane
        end
      end

      context 'fail: general elibigibility validation fails' do
        # response 'fail' 'attendee is banned as a competitor' do
        #   # TODO: write
        #   # NOTE: We need to figure out what the scope of bans are - do they prevent a user from registering at all, or only certain lanes?
        #   # Have contacted WDC to confirm
        # end

        # request 'fail' 'attendee has incomplete profile' do
        #   # TODO: write
        # end
      end

      context 'fail: competition elibigibility validation fails' do
        # request 'fail' 'user does not pass qualification' do
        #   # TODO: write
        # end

        # request 'fail' 'overall attendee limit reached' do
        #   # TODO: write
        #   # NOTE: This would be a combination of the currently accepted attendees, those on the waiting list, and those pending
        #   # NOTE: There are actually a few ways to implement this that we need to think through
        # end
      end
    end
  end
end
