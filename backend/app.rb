require 'sinatra'
require 'json'
require_relative './models/hashtag'

get '/' do
  Hashtag.find_by_id(1).to_json
end

def pesan 
  message = {
    'message' => "hi"
  }
  message.to_json
end

post '/user' do
  #params user
  
end

post '/post' do
  #params post
end

get '/post' do
  #params query hashtag
end

get '/hashtag' do
  #params query trending true
end

post '/post/:post_id/comment' do
#params comment
end



