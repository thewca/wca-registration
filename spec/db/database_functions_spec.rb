# frozen_string_literal: true

require 'swagger_helper'
require_relative '../support/helpers/registration_spec_helper'

RSpec.describe 'testing DynamoID writes', type: :request do
  include Helpers::RegistrationHelper

  it 'creates a registration object from a given hash' do
    basic_registration = get_registration('CubingZANationalChampionship2023-158816')

    registration = Registration.new(basic_registration)
    registration.save

    expect(Registration.count).to eq(1)
  end
end

RSpec.describe 'testing DynamoID reads', type: :request do
  include Helpers::RegistrationHelper
  include_context 'database seed'

  it 'returns registration by attendee_id as defined in the schema' do
    basic_registration = get_registration('CubingZANationalChampionship2023-158816', true)
    registration_from_database = Registration.find('CubingZANationalChampionship2023-158816')

    expect(registration_equal(registration_from_database, basic_registration)).to eq(true)
  end
end
