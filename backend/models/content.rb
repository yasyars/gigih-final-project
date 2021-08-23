class Content
  def initialize(param)
    @id = param[:id]
    @content = param[:content]
    @user = param[:user]
    @attachment = param[:attachment]
    @timestamp = param[:timestamp]
    @hashtags = param[:hashtags] || []
  end
  
  def valid?
    @content.length <= 1000 && !@content.strip.empty?
  end

  def extract_hashtag
    hashtag_pattern = /#\S+/
    hashtags = @content.downcase.scan(hashtag_pattern)
    hashtags.uniq
  end

  def raise_error_if_invalid
    raise UserNotFound if @user.nil?
  end

  def set_base_url(domain) 
    unless @attachment.nil? || @attachment.strip.empty?
      @attachment = "#{domain}/#{@attachment}"
    else
      @attachment = nil
    end
  end

  def to_hash
    raise_error_if_invalid
    {
      'id' => @id.to_i,
      'content' => @content,
      'user' => @user.to_hash,
      'attachment' => @attachment,
      'timestamp' => @timestamp,
      'hashtags' => @hashtags
    }
  end
end