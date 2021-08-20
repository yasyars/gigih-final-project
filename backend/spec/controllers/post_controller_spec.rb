require_relative '../../db/db_connector'
require_relative '../../controllers/post_controller'
require_relative '../../views/post_view'
require_relative '../../models/post'
require 'json'

describe PostController do
  before [:each] do
    client = create_db_client
    client.query("SET FOREIGN_KEY_CHECKS = 0")
    client.query("TRUNCATE TABLE posts")
    client.query("SET FOREIGN_KEY_CHECKS =1")
    client.close
  end  
  
  describe '#add_post' do
    context 'when given valid params' do
      it 'should return right response' do
        controller = PostController.new
        params = {
          'user_id' => 1,
          'content' => 'Halo semuanya #ootd',
          'attachment' => 'data/file.png'
        }

        user = double
        allow(User).to receive(:find_by_id).with(1).and_return(user)
        post = double
        allow(Post).to receive(:new).and_return(post)
        allow(post).to receive(:save)
        
        response = controller.add_post(params)
        expected_json = {
          'message' => PostView::MESSAGE[:create_success]
        }.to_json

        expect(response).to eq(expected_json)
      end
    end
  end

  describe '#get_post_with_hashtag' do
    context 'when given valid params' do
      it 'should return right response' do
        controller = PostController.new
        params = {
          'hashtag' => '#mar',
          'attachment' => 'data/file.png'
        }

        user = double
        allow(User).to receive(:find_by_id).with(1).and_return(user)
        post = double
        allow(Post).to receive(:new).and_return(post)
        allow(post).to receive(:save)
        
        response = controller.add_post(params)
        expected_json = {
          'message' => PostView::MESSAGE[:create_success]
        }.to_json

        expect(response).to eq(expected_json)
      end
    end
  end

end