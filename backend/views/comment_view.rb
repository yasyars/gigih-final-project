require_relative '../models/comment'
require 'json'

class CommentView

  MESSAGE = {
    :status_ok => 'success',
    :create_success => 'Comment successfully created',
    :get_success =>'Comment data retrieved succesfully',
    :get_not_found => 'Comment data not found'
  }

  def create_success
    { 'status' => MESSAGE[:status_ok],
      'message' => MESSAGE[:create_success]
    }.to_json
  end

  def post_data(post)

    return empty_post if post.nil?
    response = {
      'status' => MESSAGE[:status_ok],
      'message' => MESSAGE[:get_success],
      'data' => comments.to_hash
    }.to_json
  end

  def comment_array(comments)
    response ={
      'status' => MESSAGE[:status_ok],
      'message' => MESSAGE[:get_success] ,
      'data' => comments.map {|comment| comment.to_hash}
    }
    response['message'] = MESSAGE[:get_not_found] if comments.empty? 
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