# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'dotenv/load'
require_relative './controllers/user_controller'
require_relative './controllers/post_controller'
require_relative './controllers/comment_controller'
require_relative './controllers/hashtag_controller'

set :show_exceptions, false
set :bind, '0.0.0.0'

configure do
  enable :cross_origin
end

before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

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
  status 201
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
  controller.get_comment(params,request.base_url)
end

post '/post/:post_id/comment' do
  controller = CommentController.new
  status 201
  controller.add_comment(params)
end

get '/uploads/:file_name' do
  send_file "uploads/#{params['file_name']}"
end

options "*" do
  response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  200
end
