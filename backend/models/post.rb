# frozen_string_literal: true

require_relative '../db/db_connector'
require_relative 'user'
require_relative 'hashtag'
require_relative '../exception/post_error'
require_relative '../exception/user_error'


class Post
  attr_reader :id, :content, :user, :attachment, :timestamp, :hashtags

  def initialize(param)
    @id = param[:id]
    @content = param[:content]
    @user = param[:user]
    @attachment = param[:attachment]
    @timestamp = param[:timestamp]
    @hashtags = param[:hashtags] || []
  end

  def valid?
    @content.length <= 1000 && @content.gsub(/\s+/, '') != ''
  end

  def extract_hashtag
    hashtag_pattern = /#\S+/
    hashtags = @content.downcase.scan(hashtag_pattern)
    hashtags.uniq
  end

  def save
    raise InvalidPost unless valid?
    raise UserNotFound if @user.nil?

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
    query = 'SELECT * FROM posts'
    raw_data = client.query(query)
    client.close
    return [] if raw_data.count.zero?

    posts = []
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
    return nil if raw_data.count.zero?

    posts = []
    data = raw_data.first
    Post.new({
               id: data['id'],
               content: data['content'],
               user: User.find_by_id(data['user_id']),
               attachment: data['attachment'],
               timestamp: data['timestamp']
             })
  end

  def self.find_by_hashtag_word(word)
    client = create_db_client
    query = "SELECT posts.id , posts.content , posts.user_id , posts.attachment, posts.timestamp FROM posts JOIN posts_hashtags ON posts.id = posts_hashtags.post_id JOIN hashtags ON posts_hashtags.hashtag_id = hashtags.id WHERE hashtags.word= '#{word}'"
    raw_data = client.query(query)
    client.close
    return [] if raw_data.count.zero?

    posts = []
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
    raise InvalidPost unless valid?
    raise UserNotFound if @user.nil?
    {
      'id' => @id.to_i,
      'content' => @content,
      'user' => @user.to_hash,
      'attachment' => @attachment,
      'timestamp' => @timestamp
    }
  end

  def set_domain_attachment(domain) 
    unless @attachment.nil? || @attachment.gsub(/\s+/, '')==""
      @attachment = "#{domain}/#{@attachment}"
    else
      @attachment = nil
    end
    self
  end
end
