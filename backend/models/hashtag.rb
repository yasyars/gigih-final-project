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
    raise "Invalid Hashtag" if @word.nil? || @word.gsub(/\s+/, "")=="" || !!(@word !~ /^#\S*$/)
    true
  end

end