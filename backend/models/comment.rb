require_relative '../db/db_connector'
require_relative 'post'

class Comment < Post

  def initialize(param)
    super(param)
    @post = param[:post]
  end

  def valid?
    super && !@post.nil?
  end

  def save
    raise ArgumentError.new("Invalid Comment") unless valid?
    client = create_db_client
    query = "INSERT INTO comments (content, user_id, post_id, attachment) VALUES (#{@content}, #{@user.id}, #{@post.id}, #{@attachment}"
    client.query(query)
    client.close
    @id = client.last_id
    save_with_hashtags
  end

  def save_with_hashtags
    client = create_db_client
    hashtags = extract_hashtag
    hashtags.each do |word|
      hashtag = Hashtag.save_or_find(word)
      query = "INSERT INTO comments_hashtags (comment_id, hashtag_id) VALUES (#{@id},#{hashtag.id})"
      client.query(query)
    end
    client.close
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

  def self.find_by_id(id)
    client = create_db_client
    query = "SELECT * FROM comments WHERE id = #{id}"
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

  def to_hash
    raise ArgumentError.new("Invalid Comment") unless valid?
    {
      'id' => @id,
      'content' => @content,
      'user' => @user.to_hash,
      'post' => @post.to_hash,
      'attachment' => @attachment,
      'timestamp' => @timestamp
    }
  end

end