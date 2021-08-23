# frozen_string_literal: true

require 'dotenv/load'
require_relative '../../db/db_connector'
require_relative '../../controllers/comment_controller'
require_relative '../../views/comment_view'
require_relative '../../models/comment'
require_relative '../../models/post'

require 'json'

describe CommentController do
  describe '.add_comment' do
    context 'when given valid params' do
      it 'should return right response' do
        controller = CommentController.new
        params = {
          'user_id' => '1',
          'content' => 'Halo semuanya #morning',
          'post_id' => '1',
          'attachment' => {
            'filename' => '1 copy.jpg',
            'type' => 'image/jpeg',
            'name' => 'attachment',
            'tempfile' => '<Tempfile:/var/folders/53/0gnz9zd53qg9srl770x812gr0000gn/T/RackMultipart20210821-2727-ebzsq8.jpg>',
            'head' => "Content-Disposition: form-data; name=\"attachment\"; filename=\"1 copy.jpg\"\r\nContent-Type: image/jpeg\r\n"
          }
        }

        user = double
        allow(User).to receive(:find_by_id).with('1').and_return(user)
        post = double
        allow(Post).to receive(:find_by_id).with('1').and_return(post)

        file_stub = double
        allow(FileHandler).to receive(:new).and_return(file_stub)
        allow(file_stub).to receive(:upload).with(params['attachment']).and_return('uploads/data.png')

        comment = double
        allow(Comment).to receive(:new).and_return(comment)
        allow(comment).to receive(:save)

        response = controller.add_comment(params)
        expected_json = {
          'status' => CommentView::MESSAGE[:status_ok],
          'message' => CommentView::MESSAGE[:create_success]
        }.to_json

        expect(response).to eq(expected_json)
      end
    end
  end

  describe '.get_comment_by_hashtag' do
    context 'when given valid params' do
      it 'should return right response' do
        controller = CommentController.new

        params = {
          'hashtag'=> '#ootd',
          'post_id' => '1'
        }
                                                
        post = double
        allow(Post).to receive(:find_by_id).with(params['post_id']).and_return(post)
        allow(post).to receive(:find_comment_by_hashtag_word).with(params['hashtag']).and_return([])

        response = controller.get_comment_by_hashtag(params,'localhost')
        expected_json = response = {
          'status' => CommentView::MESSAGE[:status_ok],
          'message' => CommentView::MESSAGE[:get_not_found],
          'data' => []
        }.to_json

        expect(response).to eq(expected_json)
      end
    end
  end

  describe '.get_comment' do
    context 'when given hashtag params' do
      it 'should call get_comment_by_hashtag' do
        controller = CommentController.new

        params = {
          'hashtag'=> '#ootd',
          'post_id' => '1'
        }
                                                
        expect(controller).to receive(:get_comment_by_hashtag)
        controller.get_comment(params,'localhost')
      end
    end

    context 'when given no hashtag params' do
      it 'should call get_all_comment' do
        controller = CommentController.new

        params = {
          'hashtag'=> '   ',
          'post_id' => '1'
        }
                                                
        expect(controller).to receive(:get_all_comment)
        controller.get_comment(params,'localhost')
      end
    end
  end
end
