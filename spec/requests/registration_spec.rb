require 'swagger_helper'

RSpec.describe 'api/registration', type: :request do
  path '/api/registration' do
    get 'List registrations' do
      parameter competition_id: :string
      produces 'application/json'


      context "success responses" do

        response '200', 'request and response conform to schema' do
          schema type: :object, 
            properties {
              # TODO when database structure is finalised
            }
          
          let!(:competition_id) { 'RegistrationTestComp'}
          run_test!
        end 

        response '200', 'User is allowed to access registration data (various scenarios)' do
        end

      response '400', 'Competition ID parameter mis-spelled' do
      end

      response '400', 'Competition ID not provided' do
      end

      response '401', 'Tampered JWT token rejected' do
      end

      response '404', 'Comeptition ID doesnt exist' do
      end

      response '403', 'User is not allowed to access registration data (various scenarios)' do
      end
      
      response '502', 'Competition service unavailable' do
      end



    end
  end
  # test change
end
