require_relative '../db/db_connector'
require_relative 'user'

class Comment 
  attr_reader :id, :content, :user, :attachment, :timestamp, :hashtags

  def initialize(param)
    @id = param[:id] ? param[:id] : nil
    @content = param[:content]
    @user = param[:user]
    @post = param[:post]
    @attachment = param[:attachment] ? param[:attachment] : nil
    @timestamp = param[:timestamp] ? param[:timestamp] : nil
    @hashtags = param[:hashtags] ? param[:hashtags] : []
  end

  def valid?
    @content.length <= 1000 && @content.gsub(/\s+/, "")!=""
  end


end