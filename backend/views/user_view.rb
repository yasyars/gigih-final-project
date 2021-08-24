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

  def initialize
    @status = MESSAGE[:status_ok]
    @message = MESSAGE[:get_not_found]
    @data = nil
  end

  def create_success
    @message = MESSAGE[:create_success]
    {
      'status' => @status,
      'message' => @message
    }.to_json
  end

  def user_data(user)
    return send_result if user.nil?
    @message = MESSAGE[:get_success]
    @data= user.to_hash
    send_result
  end

  def send_result
    {
      'status' => @status,
      'message' => @message,
      'data' => @data
    }.to_json
  end
end
