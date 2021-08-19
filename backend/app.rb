require 'sinatra'
require 'json'

get '/' do
  hello = {
    'message' => "hello world"
  }

  hello.to_json
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



