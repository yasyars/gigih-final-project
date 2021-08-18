require_relative '../db/db_connector'
require_relative 'post'

class Comment < Post

  def initialize(param)
    super(param)
    @user = param[:user]
  end

  def self.find_by_hashtag(hashtag)
    client = create_db_client
    query = "SELECT * FROM comments JOIN comments_hashtags ON comments.id = comments_hashtags.comment_id WHERE hashtag_id = #{hashtag.id}"
    raw_data = client.query(query)
    client.close
    return [] if raw_data.count == 0 
    comments = Array.new
    raw_data.each do |data|
      comment = Comment.new({
        id: data['id'],
        content: data['content'],
        user: User.find_by_id(data['user_id']),
        post: Post.find_by_id(data['post_id']),
        attachment: data['attachment'],
        timestamp: data['timestamp']
      })
      comments.push(comment)
    end
    comments
  end

end