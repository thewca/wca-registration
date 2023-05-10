require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test 'should create registration' do
    $dynamodb.stub_responses(:put_item, {})

    post '/register', params: {
      competitor_id: '2003BRUC01',
      competition_id: 'Worlds2003',
      event_ids: ['333', '444']
    }

    assert_response :success
  end
end
