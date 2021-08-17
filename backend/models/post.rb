require_relative '../db/db_connector'

class Post 
  attr_reader :id, :content, :user, :attachment, :timestamp, :hashtags

  def initialize(param)
    @id = param[:id] ? param[:id] : nil
    @content = param[:content]
    @user = param[:user]
    @attachment = param[:attachment] ? param[:attachment] : nil
    @timestamp = param[:timestamp] ? param[:timestamp] : nil
    @hashtags = param[:hashtags] ? param[:hashtags] : []
  end

  def valid?
    @content.length <= 1000
  end


end