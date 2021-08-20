require_relative '../models/hashtag'
require 'json'

class HashtagView

  MESSAGE = {
    :status_ok => 'success',
    :get_success =>'Hashtag data retrieved succesfully',
  }

  def hashtag_array(hashtags)
    response ={
      'status' => MESSAGE[:status_ok],
      'message' => MESSAGE[:get_success] ,
      'data' => hashtags.map {|hashtag| hashtag.to_hash}
    }
    response['message'] = MESSAGE[:get_not_found] if hashtags.empty? 
    response.to_json
  end
  
end