require 'sinatra'
require 'json'
require_relative './controllers/user_controller'
require_relative './controllers/post_controller'
require_relative './controllers/hashtag_controller'


set :show_exceptions, false

get '/' do
  Hashtag.save_or_find('#helloworld').to_hash.to_json
end

error ArgumentError do
  status 400
  {'status' => 'error',
   'message' =>  env['sinatra.error'].message }.to_json 
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
  controller = PostController.new
  status 200
  controller.add_post(params)
end

get '/post' do
  word = params['hashtag'] ? params['hashtag'] : nil
  controller = PostController.new
  status 200
  controller.get_post(word)
end

get '/hashtag/trending' do
  controller = HashtagController.new
  status 200
  controller.get_trending
end

post '/post/:post_id/comment' do
 controller = CommentController.new
 status 200
 controller.add_comment(params['post_id'])
end



