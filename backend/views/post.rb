require_relative '../models/post'
require 'json'

class PostView
  def post_data(post)
    post = {
      'id' => post.id,
      'content' => post.content,
      'user' => UserView.user_data(post.user),
      'attachment' => post.attachment,
      'timestamp' => post.timestamp,
      'hashtags'=> PostView.array_hashtags(post.hashtags)
    }
    
    post.to_json
  end
end