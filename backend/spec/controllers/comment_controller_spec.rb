require_relative '../../db/db_connector'
require_relative '../../controllers/comment_controller'
require_relative '../../views/comment_view'
require_relative '../../models/comment'
require 'json'

describe CommentController do
  before [:each] do
    client = create_db_client
    client.query("SET FOREIGN_KEY_CHECKS = 0")
    client.query("TRUNCATE TABLE comments")
    client.query("SET FOREIGN_KEY_CHECKS =1")
    client.close
  end  
  
  describe '#add_comment' do
    context 'when given valid params' do
      it 'should return right response' do
        controller = CommentController.new
        params = {
          'user_id' => 1,
          'post_id'=>1,
          'content' => 'Halo semuanya #ootd',
          'attachment' => 'data/file.png'
        }

        user = double
        allow(User).to receive(:find_by_id).with(1).and_return(user)
        post = double
        allow(User).to receive(:find_by_id).with(1).and_return(post)
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

  describe '#get_comment_by_hashtag_word' do
    context 'when given valid params' do
      it 'should return right response' do
        controller = CommentController.new
        comment = double
        user = double
        allow(user).to receive(:to_hash).and_return({
          'id' => 1,
          'username' => 'merygorund',
          'email' => 'mery@go.round',
          'bio' => 'A ruby lover'
        })
        allow(Comment).to receive(:find_by_hashtag_word).and_return([comment])
        allow(comment).to receive(:to_hash).and_return({
          'id' =>1,
          'content' => "Hai semuanya #ootd",
          'user' => user.to_hash,
          'attachment' => 'data/file.png'
        })

        response = controller.get_comment_by_hashtag('#ootd')
        expected_json = response ={
          'status' => CommentView::MESSAGE[:status_ok],
          'message' => CommentView::MESSAGE[:get_success] ,
          'data' => [comment.to_hash]
        }.to_json

        expect(response).to eq(expected_json)
      end
    end
  end

end