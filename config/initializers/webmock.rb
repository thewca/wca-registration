# frozen_string_literal: true

if Rails.env.local?
  require 'webmock'
  WebMock.disable_net_connect!(allow: [
    'localhost',
    'http://localstack:4566',
    'http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/registrations.fifo'
  ])
  # WebMock.disable_net_connect!(allow: 'http://localstack:4566')
  # WebMock.allow_net_connect! # This is necesary because localstack errors out otherwise
end
