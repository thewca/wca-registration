# frozen_string_literal: true

class UserController < ApplicationController
  skip_before_action :validate_token, only: [:info]

  def info
    user_ids = params.require(:ids)
    data = RedisHelper.cache_info_by_ids('user-info', user_ids) do |ids|
      UserApi.get_user_info(ids)['users']
    end
    render json: data
  end
end
