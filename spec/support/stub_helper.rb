# frozen_string_literal: true

def stub_json(url, response_code, payload, type = :get)
  stub_request(type, url).to_return(
    status: response_code,
    body: payload.to_json,
    headers: { 'Content-Type' => 'application/json' },
  )
end

def stub_pii(user_ids)
  user_pii = user_ids.map do |user_id| 
    {
      id: user_id,
      email: "#{user_id}@example.com",
      dob: '1950-04-04',
    }
  end

  stub_json(UserApi.competitor_info_path, 200, user_pii, :post)
end
