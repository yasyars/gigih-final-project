require_relative '../db/db_connector'
require_relative 'user'
class Post 
  attr_reader :id, :content, :user, :attachment, :timestamp, :hashtags

  def initialize(param)
    @id = param[:id] ? param[:id] : nil
    @content = param[:content]
    @user = param[:user]
    @attachment = param[:attachment] ? param[:attachment] : nil
    @timestamp = param[:timestamp] ? param[:timestamp] : nil
    @hashtags = param[:hashtags] ? param[:hashtags] : []
  end

  def valid?
    @content.length <= 1000 && @content.gsub(/\s+/, "")!=""
  end

  def extract_hashtag
    hashtag_pattern = /#\S+/
    hashtags = @content.downcase.scan(hashtag_pattern)
    hashtags.uniq
  end

  def self.find_by_hashtag(hashtag)
    client = create_db_client
    query = "SELECT * FROM posts JOIN posts_hashtags ON posts.id = posts_hashtags.post_id WHERE hashtag_id = #{hashtag.id}"
    raw_data = client.query(query)
    client.close
    return [] if raw_data.count == 0 
    posts = Array.new
    raw_data.each do |data|
      post = Post.new({
        id: data['id'],
        content: data['content'],
        user: User.find_by_id(data['id']),
        attachment: data['attachment'],
        timestamp: data['timestamp']
      })
      posts.push(post)
    end
    posts
  end


end