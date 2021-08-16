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

end