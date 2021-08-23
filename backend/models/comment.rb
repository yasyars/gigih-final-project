# frozen_string_literal: true

require_relative '../db/db_connector'
require_relative '../exception/comment_error'
require_relative '../exception/post_error'
require_relative '../exception/user_error'

class Comment
  attr_accessor :hashtags

  def initialize(param)
    @id = param[:id]
    @content = param[:content]
    @user = param[:user]
    @attachment = param[:attachment]
    @timestamp = param[:timestamp]
    @hashtags = param[:hashtags] || []
    @post = param[:post]
  end

  def valid?
    @content.length <= 1000 && @content.gsub(/\s+/, '') != ''
  end

  def extract_hashtag
    hashtag_pattern = /#\S+/
    hashtags = @content.downcase.scan(hashtag_pattern)
    hashtags.uniq
  end

  def raise_error_if_invalid
    raise InvalidComment unless valid?
    raise UserNotFound if @user.nil?
    raise PostNotFound if @post.nil?
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
    return [] if raw_data.count.zero?

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
    raise_error_if_invalid
    {
      'id' => @id,
      'content' => @content,
      'user' => @user.to_hash,
      'post' => @post.to_hash,
      'attachment' => @attachment,
      'timestamp' => @timestamp,
      'hashtags' => @hashtags
    }
  end
end
