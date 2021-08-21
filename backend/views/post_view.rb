# frozen_string_literal: true

require_relative '../models/post'
require 'json'

class PostView
  MESSAGE = {
    status_ok: 'success',
    create_success: 'Post successfully created',
    get_success: 'Post data retrieved succesfully',
    get_not_found: 'Post data not found'
  }.freeze

  def create_success
    { 'status' => MESSAGE[:status_ok],
      'message' => MESSAGE[:create_success] }.to_json
  end

  def post_data(post)
    return empty_post if post.nil?

    response = {
      'status' => MESSAGE[:status_ok],
      'message' => MESSAGE[:get_success],
      'data' => post.to_hash
    }
    response.to_json
  end

  def post_array(posts)
    response = {
      'status' => MESSAGE[:status_ok],
      'message' => MESSAGE[:get_success],
      'data' => posts.map(&:to_hash)
    }
    response['message'] = MESSAGE[:get_not_found] if posts.empty?
    response.to_json
  end

  def empty_post
    {
      'status' => MESSAGE[:status_ok],
      'message' => MESSAGE[:get_not_found],
      'data' => nil
    }.to_json
  end
end
