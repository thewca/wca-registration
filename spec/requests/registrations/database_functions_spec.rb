require 'swagger_helper'
require_relative '../../support/helpers/registration_spec_helper'

RSpec.describe 'testing DynamoID writes', type: :request do
  include Helpers::RegistrationHelper

  it 'creates a registration object from a given hash' do
    # TODO - get this from 'registration_data' context - not sure why it isn't working currently
    basic_registration = get_registration('CubingZANationalChampionship2023-158816')

    # Error message here prints out an array and says there's no method "key?", but the return value of get_registration
    # is definitely a hash
    registration = Registrations.new(basic_registration)
    registration.save

    expect(Registrations.count).to eq(1)
  end
end

RSpec.describe 'testing DynamoID reads', type: :request do
  include Helpers::RegistrationHelper
  inlude_context 'Database seed'

  it 'returns registration by attendee_id as defined in the schema' do
    # TODO - get this from 'registration_data' context - not sure why it isn't working currently
    basic_registration = get_registration('CubingZANationalChampionship2023-158816')
    registration_from_database = Registrations.find('CubingZANationalChampionship2023-158816')

    expect(registration_from_database).to_eq()
  end
end
