# frozen_string_literal: true

if Rails.env.local?
  require 'webmock'
  WebMock.disable_net_connect!(allow: 'http://localstack:4566')
end
