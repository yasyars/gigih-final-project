# frozen_string_literal: true

require 'sinatra'
require 'json'
require_relative './controllers/user_controller'
require_relative './controllers/post_controller'
require_relative './controllers/comment_controller'
require_relative './controllers/hashtag_controller'

set :show_exceptions, false

error do
  status 400
  { 'status' => 'fail',
    'error'  => {
      'type'=> env['sinatra.error'].class,
      'message' => env['sinatra.error'].message 
    }
  }.to_json
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
  word = params['hashtag']
  controller = PostController.new
  status 200
  controller.get_post(word, request.base_url)
end

get '/hashtag/trending' do
  controller = HashtagController.new
  status 200
  controller.get_trending
end

get '/post/:post_id/comment' do
  controller = CommentController.new
  status 200
  controller.get_comment(params)
end

post '/post/:post_id/comment' do
  controller = CommentController.new
  status 200
  controller.add_comment(params)
end

get '/uploads/:file_name' do
  send_file "uploads/#{params['file_name']}"
end
