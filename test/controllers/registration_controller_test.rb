require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test 'should create registration' do
    $dynamodb.stub_responses(:put_item, {})

    post '/register', params: {
      competitor_id: '123',
      competition_id: '456',
      event_ids: ['333', '444']
    }

    assert_response :success
  end
end
