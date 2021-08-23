# frozen_string_literal: true

require 'dotenv/load'
require_relative '../../db/db_connector'
require_relative '../../controllers/post_controller'
require_relative '../../views/post_view'
require_relative '../../models/post'
require_relative '../../helper/file_handler'

require 'json'

describe PostController do
  before [:each] do
    @controller = PostController.new
    @params = {
      'user_id' => '1',
      'content' => 'Halo semuanya #morning'
    }
  end
  
  describe '.add_post' do
    context 'when given valid params' do
      it 'should return right response' do
        @params['attachment']={
          'filename' => '1 copy.jpg',
          'type' => 'image/jpeg',
          'name' => 'attachment',
          'tempfile' => '<Tempfile:/var/folders/53/0gnz9zd53qg9srl770x812gr0000gn/T/RackMultipart20210821-2727-ebzsq8.jpg>',
          'head' => "Content-Disposition: form-data; name=\"attachment\"; filename=\"1 copy.jpg\"\r\nContent-Type: image/jpeg\r\n"
        }

        user = double
        allow(User).to receive(:find_by_id).with('1').and_return(user)

        file_stub = double
        allow(FileHandler).to receive(:new).and_return(file_stub)
        allow(file_stub).to receive(:upload).with(@params['attachment']).and_return('uploads/data.png')

        post = double
        allow(Post).to receive(:new).and_return(post)
        allow(post).to receive(:save)

        response = @controller.add_post(@params)
        expected_json = {
          'status' => PostView::MESSAGE[:status_ok],
          'message' => PostView::MESSAGE[:create_success]
        }.to_json

        expect(response).to eq(expected_json)
      end
    end

    context 'when there is no attachment' do
      it 'should assign nil to the path' do
        file_stub = double
        expect(FileHandler).not_to receive(:new)

        post = double
        allow(Post).to receive(:new).and_return(post)
        allow(post).to receive(:save)

        response = @controller.add_post(@params)
      end
    end
  end

  describe '.get_post_by_hashtag' do
    context 'when given valid params' do
      it 'should return right response' do
        post = double
        user = double
        allow(user).to receive(:to_hash).and_return({
                                                      'id' => 1,
                                                      'username' => 'merygorund',
                                                      'email' => 'mery@go.round',
                                                      'bio' => 'A ruby lover'
                                                    })

        posts = [post]
        allow(Post).to receive(:find_by_hashtag_word).and_return(posts)
        allow(post).to receive(:set_domain_attachment).with('http://localhost:4567').and_return(posts)
        allow(posts).to receive(:map).and_return(posts)
        allow(post).to receive(:to_hash).and_return({
                                                      'id' => 1,
                                                      'content' => 'Hai semuanya #ootd',
                                                      'user' => user.to_hash,
                                                      'attachment' => nil
                                                    })

        response = @controller.get_post_by_hashtag('#ootd', 'http://localhost:4567')
        expected_json = response = {
          'status' => PostView::MESSAGE[:status_ok],
          'message' => PostView::MESSAGE[:get_success],
          'data' => [post.to_hash]
        }.to_json

        expect(response).to eq(expected_json)
      end
    end
  end

  describe '.get_post' do
    context 'when given hashtag params' do
      it 'should call get_post_by_hashtag' do
        expect(@controller).to receive(:get_post_by_hashtag).with('#halo','localhost')
        @controller.get_post('#halo','localhost')
      end
    end

    context 'when given no hashtag params' do
      it 'should call get_all_post' do                         
        expect(@controller).to receive(:get_all_post)
        @controller.get_post('   ','localhost')
      end
    end
  end

  describe '.get_all_post' do
    context 'when given valid params' do
      it 'should send all post result from Post find all' do
        post1 = double
        post2 = double
        posts = [post1,post2]
        allow(Post).to receive(:find_all).and_return(posts)
        allow(posts).to receive(:map)
        stub_response = double
        expect(@controller.response).to receive(:post_array).with(posts)
        @controller.get_all_post('localhost')
      end
    end
  end
end
