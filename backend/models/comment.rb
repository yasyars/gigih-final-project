# frozen_string_literal: true

require_relative '../db/db_connector'
require_relative 'content'
require_relative '../exception/comment_error'
require_relative '../exception/post_error'
require_relative '../exception/user_error'

class Comment < Content
  attr_accessor :hashtags

  def initialize(param)
    super(param)
    @post = param[:post]
  end

  def raise_error_if_invalid
    super
    raise PostNotFound if @post.nil?
    raise InvalidComment unless valid?
  end

  def save
    raise_error_if_invalid
    client = create_db_client
    query = "INSERT INTO comments (content, user_id, post_id, attachment) VALUES ('#{@content}', #{@user.id}, #{@post.id}, '#{@attachment}')"
    puts query
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
      query = "INSERT INTO comments_hashtags (comment_id, hashtag_id) VALUES (#{@id},#{hashtag.id})"
      client.query(query)
    end
    client.close
  end

  def self.find_by_hashtag_word(word)
    client = create_db_client
    query = "SELECT comments.id , comments.content , comments.post_id, comments.user_id , comments.attachment, comments.timestamp FROM comments JOIN comments_hashtags ON comments.id = comments_hashtags.comment_id JOIN hashtags ON comments_hashtags.hashtag_id = hashtags.id WHERE hashtags.word= '#{word}'"
    raw_data = client.query(query)
    client.close
    get_array_from_query_result(raw_data)
  end

  def self.find_by_post_id(post_id)
    client = create_db_client
    query = "SELECT * FROM comments WHERE post_id = #{post_id}"
    raw_data = client.query(query)
    client.close
    get_array_from_query_result(raw_data)
  end

  def self.get_array_from_query_result(raw_data)
    comments = []
    raw_data.each do |data|
      comment = Comment.new({
                              id: data['id'],
                              content: data['content'],
                              user: User.find_by_id(data['user_id']),
                              post: Post.find_by_id(data['post_id']),
                              attachment: data['attachment'],
                              timestamp: data['timestamp']
                            })
      comment.hashtags = comment.extract_hashtag
      comments.push(comment)
    end
    comments
  end

  def to_hash
    hash = super
    hash['post'] = @post.to_hash
    hash
  end
end
