require_relative '../models/post'
require 'json'

class PostView

  MESSAGE = {
    :status_ok => 'success',
    :create_success => 'Post successfully created',
    :get_success =>'Post data retrieved succesfully',
    :get_not_found => 'Post data not found'
  }

  def create_success
    { 'status' => MESSAGE[:status_ok],
      'message' => MESSAGE[:create_success]
    }.to_json
  end

  def post_data(user)
    {
      'status' => MESSAGE[:status_ok],
      'message' => MESSAGE[:get_success],
      'data' => post.to_hash
    }.to_json
  end

  def empty_post
    {
      'status' => MESSAGE[:status_ok],
      'message' => MESSAGE[:get_not_found],
      'data' => nil
    }.to_json
  end
  
end