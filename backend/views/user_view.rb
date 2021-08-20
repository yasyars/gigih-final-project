require_relative '../models/user'
require_relative '../helper/view_message'
require 'json'

class UserView

  MESSAGE= {
    :get_not_found => "ahahshs"
  }

  def create_success
    {'message' => USER_MESSAGE[:create_success]}.to_json
  end

  def user_data(user)
    {'message' => MESSAGE[:get_success],
      'data' => user.to_hash}.to_json
  end

  def empty_user
    {'message' => MESSAGE[:get_not_found],
      'data' => nil}.to_json
  end
end