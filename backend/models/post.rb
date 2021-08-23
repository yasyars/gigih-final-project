# frozen_string_literal: true

require_relative '../db/db_connector'
require_relative 'user'
require_relative 'hashtag'
require_relative 'content'
require_relative 'comment'
require_relative '../exception/post_error'
require_relative '../exception/user_error'


class Post < Content
  attr_reader :id, :content, :attachment, :timestamp
  attr_accessor :hashtags
  
  def raise_error_if_invalid
    super
    raise InvalidPost unless valid?
  end

  def save
    raise_error_if_invalid
    client = create_db_client
    query = "INSERT INTO posts (content, user_id, attachment) VALUES ('#{@content}', #{@user.id}, '#{@attachment}')"
    client.query(query)
    @id = client.last_id
    client.close
    save_hashtags
  end

  def save_hashtags
    client = create_db_client
    hashtags = extract_hashtag
    hashtags.each do |word|
      hashtag = Hashtag.save_or_find(word)
      @hashtags.push(hashtag)
      query = "INSERT INTO posts_hashtags (post_id, hashtag_id) VALUES (#{@id},#{hashtag.id})"
      client.query(query)
    end
    client.close
  end

  def self.get_array_from_query_result(raw_data)
    posts = []
    raw_data.each do |data|
      post = Post.new({
                        id: data['id'],
                        content: data['content'],
                        user: User.find_by_id(data['user_id']),
                        attachment: data['attachment'],
                        timestamp: data['timestamp']
                      })
      post.hashtags = post.extract_hashtag
      posts.push(post)
    end
    posts
  end

  def self.find_all
    client = create_db_client
    query = 'SELECT * FROM posts'
    raw_data = client.query(query)
    client.close
    get_array_from_query_result(raw_data)
  end

  def self.get_object_from_query_result(raw_data)
    return nil if raw_data.count.zero?

    data = raw_data.first
    post = Post.new({
              id: data['id'],
              content: data['content'],
              user: User.find_by_id(data['user_id']),
              attachment: data['attachment'],
              timestamp: data['timestamp']
            })
    post.hashtags = post.extract_hashtag
    post
  end

  def self.find_by_id(id)
    client = create_db_client
    query = "SELECT * FROM posts WHERE id = #{id}"
    raw_data = client.query(query)
    client.close
    get_object_from_query_result(raw_data)
  end

  def self.find_by_hashtag_word(word)
    client = create_db_client
    query = "SELECT posts.id , posts.content , posts.user_id , posts.attachment, posts.timestamp FROM posts JOIN posts_hashtags ON posts.id = posts_hashtags.post_id JOIN hashtags ON posts_hashtags.hashtag_id = hashtags.id WHERE hashtags.word= '#{word}'"
    raw_data = client.query(query)
    client.close
    get_array_from_query_result(raw_data)
  end

  def find_comment_by_hashtag_word(word)
    client = create_db_client
    query = "SELECT comments.id , comments.content , comments.post_id, comments.user_id , comments.attachment, comments.timestamp FROM comments JOIN comments_hashtags ON comments.id = comments_hashtags.comment_id JOIN hashtags ON comments_hashtags.hashtag_id = hashtags.id WHERE hashtags.word= '#{word}' AND comments.post_id = #{@id}"
    raw_data = client.query(query)
    client.close
    Comment.get_array_from_query_result(raw_data)
  end
end
