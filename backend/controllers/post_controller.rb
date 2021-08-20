require_relative '../models/post'
require_relative '../models/user'
require_relative '../views/post_view'

class PostController
  def add_post(params)
    user = User.find_by_id(params['user_id'].to_i)
    post = Post.new({
      content: params['content'],
      user: user,
      attachment: params['attachment']
    })
    post.save
    response = PostView.new
    response.create_success
  end
end