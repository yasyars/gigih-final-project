# frozen_string_literal: true

require_relative '../models/hashtag'
require 'json'

class HashtagView
  MESSAGE = {
    status_ok: 'success',
    get_success: 'Hashtag data retrieved succesfully',
    get_not_found: 'No hashtag matched'
  }.freeze

  def initialize
    @status = MESSAGE[:status_ok]
    @message = MESSAGE[:get_not_found]
    @data = nil
  end

  def hashtag_array(hashtags)
    @message = MESSAGE[:get_success] unless hashtags.empty?
    @data = hashtags.map(&:to_hash)
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
