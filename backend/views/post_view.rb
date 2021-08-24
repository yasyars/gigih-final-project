# frozen_string_literal: true

require_relative '../models/post'
require 'json'

class PostView
  MESSAGE = {
    status_ok: 'success',
    create_success: 'Post successfully created',
    get_success: 'Post data retrieved succesfully',
    get_not_found: 'No post matched'
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

  def post_data(post)
    return send_result if post.nil?
    @message =  MESSAGE[:get_success]
    @data = post.to_hash
    send_result
  end

  def post_array(posts)
    if posts.empty? 
      @message = MESSAGE[:get_not_found]
    else
      @message = MESSAGE[:get_success]
    end

    @data = posts.map(&:to_hash)
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
