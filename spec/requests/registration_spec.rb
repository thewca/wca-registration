# frozen_string_literal: true

require 'swagger_helper'
require_relative 'get_registrations_spec'
require_relative 'post_attendee_spec'
require_relative '../support/registration_spec_helper'

# TODO: Write more tests for other cases according to airtable

# TODO: See if shared contexts can be put into a helper file once tests are passing
# TODO: Refactor these into a shared example once they are passing
RSpec.describe 'v1 Registrations API', type: :request do
  include Helpers::RegistrationHelper

  # TODO: POST registration tests
  # TODO: Validate the different lanes against their schemas
  # TODO: Figure out how to validate that webhook responses are receive? (that might be an integration/end-to-end test)
end
# TODO: Add tests for competition_id, user_id and validity of attendee_id
