# frozen_string_literal: true

class ApplicationController < ActionController::API
  around_action :performance_profile if Rails.env == 'development'

  def performance_profile
    if params[:profile] && result = RubyProf.profile { yield }

      out = StringIO.new
      RubyProf::GraphHtmlPrinter.new(result).print out, :min_percent => 0
      self.response_body = out.string

    else
      yield
    end
  end
end
