# frozen_string_literal: true

require_relative '../models/comment'
require 'json'

class CommentView
  MESSAGE = {
    status_ok: 'success',
    create_success: 'Comment successfully created',
    get_success: 'Comment data retrieved succesfully',
    get_not_found: 'No comment matched'
  }.freeze

  def initialize
    @status = MESSAGE[:status_ok]
    @message = MESSAGE[:get_not_found]
    @data =nil
  end

  def create_success
    @message = MESSAGE[:create_success]
    { 
      'status' => @status,
      'message' =>  @message
    }.to_json
  end

  def post_data(post)
    return send_result if post.nil?

    @message = MESSAGE[:get_success]
    @data = comments.to_hash
    send_result
  end

  def comment_array(comments)
    @message = MESSAGE[:get_success] unless comments.empty?
    @data = comments.map(&:to_hash)
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
