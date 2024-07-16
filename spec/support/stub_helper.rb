# frozen_string_literal: true

def stub_json(url, response_code, payload, type = :get)
  stub_request(type, url).to_return(
    status: response_code,
    body: payload.to_json,
    headers: { 'Content-Type' => 'application/json' },
  )
end
