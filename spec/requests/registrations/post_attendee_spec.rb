require 'swagger_helper'
require_relative '../../support/helpers/registration_spec_helper'

RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  path '/api/v1/attendee' do
    post 'Add an attendee registration' do
      parameter name: :registration, in: :body,
                schema: { '$ref' => '#/components/schemas/registration' }, required: true

      # TODO: Figure out how to validate the data written to the database
      context 'success registration posts' do
        response '202', 'validate schema and response' do
          include_context 'Registrations'
          let(:registration) { basic_registration }

          run_test!
        end

        response '202', 'only required fields included' do
          include_context 'Registrations'
          let(:registration) { required_fields_only }

          run_test!
        end
      end

      context 'fail: request validation fails' do
        # response 'fail', 'empty json provided' do
        #   before do
        #     registration = {}
        #   end
        #     
        #   let!(:registration) { registration }

        #   run_test!
        # end

        # TODO: Figure out how to parametrize this using shared contexts/examples once it is passing
        # response 'fail', 'not all required fields included' do
        #   include_context 'Registrations'
        #   
        #   let!(:registration) { no_attendee_id }

        #   run_test!
        # end

        # response 'fail', 'spelling error on field name' do
        # # TODO: write
        # end

        # response 'fail', 'non-permitted fields included' do
        # # TODO: write
        # end
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
          # pass
        
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
