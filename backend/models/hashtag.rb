require_relative '../db/db_connector'

class Hashtag
  attr_reader :id, :word

  def initialize(param)
    @id= param[:id] ? param[:id] : nil
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
    raise "Invalid Hashtag" if !valid?
    raise "Duplicate Data" if !unique?
    client = create_db_client
    query = "INSERT INTO hashtags (word) VALUES ('#{@word}')"
    client.query(query)
    client.close
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
end