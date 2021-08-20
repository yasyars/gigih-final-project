require_relative '../models/comment'
require_relative '../models/post'
require_relative '../models/user'
require_relative '../views/comment_view'

class CommentController
  def initialize
    @response = CommentView.new
  end

  def add_comment(params)
    user = User.find_by_id(params['user_id'])
    post = Post.find_by_id(params['post_id'])
    comment = Comment.new({
      content: params['content'],
      user: user,
      post: post,
      attachment: params['attachment']
    })
    comment.save
    @response.create_success
  end

  def get_post(params)
    word = params['word']
    if word.nil?
      post = Post.find_by_id(params['post_id'])
      @response.post_array(post.comments)
    else
      get_comment_by_hashtag(word)
    end
  end

  def get_comment_by_hashtag(word)
    response = CommentView.new
    comments = Comment.find_by_hashtag_word(word)
    @response.comment_array(comments)
  end
end