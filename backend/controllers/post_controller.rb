# frozen_string_literal: true

require_relative '../models/post'
require_relative '../models/user'
require_relative '../views/post_view'
require_relative '../helper/file_handler'

class PostController
  attr_reader :response

  def initialize
    @response = PostView.new
  end

  def add_post(params)
    user = User.find_by_id(params['user_id'])
    
    if params['attachment'] 
      file_handler = FileHandler.new
      path_file = file_handler.upload(params['attachment']) 
    else
      path_file = nil
    end

    post = Post.new({
                      content: params['content'],
                      user: user,
                      attachment: path_file
                    })
    post.save
    @response.create_success
  end

  def get_post(word, domain)
    if word.nil? || word.strip.empty?
      get_all_post(domain)
    else
      get_post_by_hashtag(word, domain)
    end
  end

  def get_all_post(domain)
    posts = Post.find_all
    posts.map { |post| post.set_base_url(domain) }
    @response.post_array(posts)
  end

  def get_post_by_hashtag(word, domain)
    posts = Post.find_by_hashtag_word(word)
    posts.map { |post| post.set_base_url(domain) }
    @response.post_array(posts)
  end
end
