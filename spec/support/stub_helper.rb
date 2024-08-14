# frozen_string_literal: true

def stub_json(url, response_code, payload, type = :get)
  stub_request(type, url).to_return(
    status: response_code,
    body: payload.to_json,
    headers: { 'Content-Type' => 'application/json' },
  )
end

def stub_qualifications(payload=nil, qualification_data_date=nil)
  url_regex = %r{#{Regexp.escape(EnvConfig.WCA_HOST)}/api/v0/results/\d+/qualification_data(\?date=\d{4}-\d{2}-\d{2})?}
  stub_request(:get, url_regex).to_return do |request|
    uri = URI(request.uri)
    params = URI.decode_www_form(uri.query || '').to_h
    date = params['date']
    payload_date = qualification_data_date || date

    if !payload.nil? # Present doesnt work because [].present? == false
      { status: 200, body: payload.to_json, headers: { 'Content-Type' => 'application/json' } }
    elsif payload_date.present?
      { status: 200, body: QualificationResultsFaker.new(payload_date).qualification_results.to_json, headers: { 'Content-Type' => 'application/json' } }
    else
      { status: 200, body: QualificationResultsFaker.new.qualification_results.to_json, headers: { 'Content-Type' => 'application/json' } }
    end
  end
end
