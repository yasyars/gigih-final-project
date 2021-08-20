require_relative '../models/hashtag'
require_relative '../views/hashtag_view'

class HashtagController
  def get_trending
    response = HashtagView.new
    hashtags = Hashtag.find_trending
    response.hashtag_array(hashtags)
  end
end