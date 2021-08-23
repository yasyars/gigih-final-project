# frozen_string_literal: true

require_relative '../models/comment'
require_relative '../models/post'
require_relative '../models/user'
require_relative '../exception/post_error'
require_relative '../views/comment_view'
require_relative '../helper/file_handler'

class CommentController
  def initialize
    @response = CommentView.new
  end

  def add_comment(params)
    user = User.find_by_id(params['user_id'])
    post = Post.find_by_id(params['post_id'])
    file_handler = FileHandler.new
    
    if params['attachment'] 
      path_file = file_handler.upload(params['attachment']) 
    else
      path_file = nil
    end

    comment = Comment.new({
                            content: params['content'],
                            user: user,
                            post: post,
                            attachment: path_file
                          })
    comment.save
    @response.create_success
  end

  def get_comment(params, domain)
    word = params['hashtag']
    if word.nil? || word.strip.empty?
      get_all_comment(params,domain)
    else
      get_comment_by_hashtag(params,domain)
    end
  end

  def get_all_comment(params,domain)
    comments = Comment.find_by_post_id(params['post_id'])
    comments.map { |comment| comment.set_base_url(domain) }

    @response.comment_array(comments)
  end

  def get_comment_by_hashtag(params,domain)
    response = CommentView.new
    post = Post.find_by_id(params['post_id'])
    raise PostNotFound if post.nil?

    comments = post.find_comment_by_hashtag_word(params['hashtag']) 
    comments.map { |comment| comment.set_base_url(domain) }
    @response.comment_array(comments)
  end
end
