require_relative '../models/post'
require_relative '../models/user'
require_relative '../views/post_view'

class PostController
  def initialize
    @response = PostView.new
  end

  def add_post(params)
    user = User.find_by_id(params['user_id'])
    post = Post.new({
      content: params['content'],
      user: user,
      attachment: params['attachment']
    })
    post.save
    @response.create_success
  end

  def get_post(word)
    if word.nil?
      posts = Post.find_all
      @response.post_array(posts)
    else
      get_post_by_hashtag(word)
    end
  end

  def get_post_by_hashtag(word)
    response = PostView.new
    posts = Post.find_by_hashtag_word(word)
    @response.post_array(posts)
  end
end