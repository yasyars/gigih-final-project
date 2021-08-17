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
    hashtag_pattern = /^#\S*$/
    return !@word.nil? && @word.gsub(/\s+/, "")!="" && !!(@word =~ hashtag_pattern)
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
end