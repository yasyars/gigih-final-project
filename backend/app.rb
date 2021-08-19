require 'sinatra'
require 'json'
require_relative './controllers/user_controller'

get '/' do
  Hashtag.save_or_find('#helloworld').to_hash.to_json
end

post '/user' do
  controller = UserController.new
  controller.register(params)
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



