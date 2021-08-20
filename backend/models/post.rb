require_relative '../db/db_connector'
require_relative 'user'
require_relative 'hashtag'

class Post 
  attr_reader :id, :content, :user, :attachment, :timestamp, :hashtags
  
  def initialize(param)
    @id = param[:id].to_i ? param[:id] : nil
    @content = param[:content]
    @user = param[:user]
    @attachment = param[:attachment] ? param[:attachment] : nil
    @timestamp = param[:timestamp] ? param[:timestamp] : nil
    @hashtags = param[:hashtags] ? param[:hashtags] : []
  end

  def valid?
    @content.length <= 1000 && @content.gsub(/\s+/, "")!="" && !@user.nil?
  end

  def extract_hashtag
    hashtag_pattern = /#\S+/
    hashtags = @content.downcase.scan(hashtag_pattern)
    hashtags.uniq
  end

  def save
    raise ArgumentError.new("Invalid Post") unless valid?
    client = create_db_client
    query = "INSERT INTO posts (content, user_id, attachment) VALUES ('#{@content}', #{@user.id}, '#{@attachment}')"
    client.query(query)
    @id = client.last_id
    client.close
    save_with_hashtags
  end

  def save_with_hashtags
    client = create_db_client
    hashtags = extract_hashtag
    hashtags.each do |word|
      hashtag = Hashtag.save_or_find(word)
      query = "INSERT INTO posts_hashtags (post_id, hashtag_id) VALUES (#{@id},#{hashtag.id})"
      client.query(query)
    end
    client.close
  end

  def self.find_all
    client = create_db_client
    query = "SELECT * FROM posts"
    raw_data = client.query(query)
    client.close
    return [] if raw_data.count == 0 

    posts = Array.new
    raw_data.each do |data|
      post = Post.new({
        id: data['id'],
        content: data['content'],
        user: User.find_by_id(data['user_id']),
        attachment: data['attachment'],
        timestamp: data['timestamp']
      })

      posts.push(post)
    end
    posts
  end

  def self.find_by_id(id)
    client = create_db_client
    query = "SELECT * FROM posts WHERE id = #{id}"
    raw_data = client.query(query)
    client.close
    return nil if raw_data.count == 0 
    posts = Array.new
    data = raw_data.first
    post = Post.new({
      id: data['id'],
      content: data['content'],
      user: User.find_by_id(data['user_id']),
      attachment: data['attachment'],
      timestamp: data['timestamp']
    })
    post
  end

  def self.find_by_hashtag_word(word)
    client = create_db_client
    query = "SELECT * FROM posts JOIN posts_hashtags ON posts.id = posts_hashtags.post_id JOIN hashtags ON posts_hashtags.hashtag_id = hashtags.id WHERE hashtags.word= '#{word}'"
    raw_data = client.query(query)
    client.close
    return [] if raw_data.count == 0 
    posts = Array.new
    raw_data.each do |data|
      post = Post.new({
        id: data['id'],
        content: data['content'],
        user: User.find_by_id(data['user_id']),
        attachment: data['attachment'],
        timestamp: data['timestamp']
      })
      posts.push(post)
    end
    posts
  end

  def to_hash
    raise ArgumentError.new("Invalid Comment") unless valid?
    {
      'id' => @id.to_i,
      'content' => @content,
      'user' => @user.to_hash,
      'attachment' => @attachment,
      'timestamp' => @timestamp
    }
  end


end