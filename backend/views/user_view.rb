# frozen_string_literal: true

require_relative '../models/user'
require 'json'

class UserView
  MESSAGE = {
    status_ok: 'success',
    create_success: 'User successfully created',
    get_success: 'User data retrieved succesfully',
    get_not_found: 'No user matched'
  }.freeze

  def create_success
    {
      'status' => MESSAGE[:status_ok],
      'message' => MESSAGE[:create_success]
    }.to_json
  end

  def user_data(user)
    return empty_user if user.nil?
    {
      'status' => MESSAGE[:status_ok],
      'message' => MESSAGE[:get_success],
      'data' => user.to_hash
    }.to_json
  end

  def empty_user
    {
      'status' => MESSAGE[:status_ok],
      'message' => MESSAGE[:get_not_found],
      'data' => nil
    }.to_json
  end
end
