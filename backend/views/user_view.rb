require_relative '../models/user'
require 'json'

class UserView
  def create_success
    {'message' => 'User successfully created'}.to_json
  end
end