require_relative '../models/user'
require 'json'

class UserView

  MESSAGE = {
  :create_success => 'User successfully created',
  :get_success =>'User data retrieved succesfully',
  :get_not_found => 'User data not found'
  }

  def create_success
    {'message' => MESSAGE[:create_success]}.to_json
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