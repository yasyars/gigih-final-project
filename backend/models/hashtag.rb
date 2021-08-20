require_relative '../db/db_connector'

class Hashtag
  attr_reader :id, :word

  def initialize(param)
    @id= param[:id].to_i ? param[:id] : nil
    @word = param[:word]
    @comments = param[:comments] ? param[:comments] : []
    @posts = param[:posts] ? param[:posts] : []
  end

  def valid?
    word_pattern = /^#\S+$/
    return !@word.nil? && @word.gsub(/\s+/, "")!="" && !!(@word =~ word_pattern)
  end

  def unique?
    client = create_db_client
    query = "SELECT COUNT(id) as count FROM hashtags WHERE word = '#{@word.downcase}'"
    raw_data = client.query(query)
    client.close
    count = raw_data.first["count"]
    count == 0
  end

  def save
    raise ArgumentError.new("Invalid Hashtag") unless valid?
    raise ArgumentError.new("Duplicate Data") unless unique?
    client = create_db_client
    query = "INSERT INTO hashtags (word) VALUES ('#{@word.downcase}')"
    client.query(query)
    client.close
  end

  def self.save_or_find(word)
    hashtag = Hashtag.new({word: word})
    hashtag.save if hashtag.unique?
    hashtag = Hashtag.find_by_word(word)
    hashtag
  end

  def self.find_by_id(id)
    client = create_db_client
    query = "SELECT * FROM hashtags WHERE id= #{id}"
    raw_data = client.query(query)
    client.close

    return nil if raw_data.count == 0

    data = raw_data.first
    hashtag = Hashtag.new({
      id: data['id'],
      word: data['word']
    })
    hashtag
  end

  def self.find_by_word(word)
    client = create_db_client
    query = "SELECT * FROM hashtags WHERE word = '#{word.downcase}'"
    raw_data = client.query(query)
    return nil if raw_data.count == 0

    data = raw_data.first
    hashtag = Hashtag.new({
      id: data['id'],
      word: data['word']
    })
    hashtag
  end

  def self.find_trending
    client = create_db_client
    query = "SELECT hashtags.id, hashtags.word
            FROM hashtags
            JOIN (SELECT post_id, hashtag_id
            		FROM posts
            		JOIN posts_hashtags ON posts.id = posts_hashtags.post_id
            		WHERE timestamp >= NOW() - INTERVAL 1 DAY

            		UNION ALL

            		SELECT comment_id, hashtag_id
            		FROM comments
            		JOIN comments_hashtags ON comments.id = comments_hashtags.comment_id
            		WHERE timestamp >= NOW() - INTERVAL 1 DAY) as hashtag_data
            ON hashtags.id = hashtag_data.hashtag_id
            GROUP BY hashtag_id
            ORDER BY COUNT(hashtag_data.post_id) DESC
            LIMIT 5;"
    raw_data = client.query(query)
    client.close

    return [] if raw_data.count == 0
    
    hashtags = Array.new
    raw_data.each do |data|
      hashtag = Hashtag.new({
        id: data['id'].to_i,
        word: data['word'].downcase
      })
      hashtags.push(hashtag)
    end
    hashtags
  end

  def to_hash
    raise ArgumentError.new("Invalid Hashtag") unless valid?
    {
      'id' => @id,
      'word' => @word.downcase
    }
  end
end