require 'sinatra'
require 'json'
require_relative './controllers/user_controller'

set :show_exceptions, false

get '/' do
  Hashtag.save_or_find('#helloworld').to_hash.to_json
end

error ArgumentError do
  status 400
  {'error' => true,
    'message' => env['sinatra.error'].message }.to_json 
end

post '/user' do
  controller = UserController.new
  status 201
  controller.register(params)
end

get '/user/:username' do
  controller = UserController.new
  status 200
  controller.get_user_by_username(params)
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



