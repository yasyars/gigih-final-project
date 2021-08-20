require_relative '../../db/db_connector'
require_relative '../../controllers/post_controller'
require_relative '../../views/post_view'
require_relative '../../models/post'
require_relative '../../helper/file_handler'

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
        params =  params = {
          "user_id"=>"1", 
          "content"=>"Halo semuanya #morning", 
          "attachment"=>{
            "filename"=>"1 copy.jpg", 
            "type"=>"image/jpeg", 
            "name"=>"attachment", 
            "tempfile"=>"<Tempfile:/var/folders/53/0gnz9zd53qg9srl770x812gr0000gn/T/RackMultipart20210821-2727-ebzsq8.jpg>",
            "head"=>"Content-Disposition: form-data; name=\"attachment\"; filename=\"1 copy.jpg\"\r\nContent-Type: image/jpeg\r\n"
          }
        }

        user = double
        allow(User).to receive(:find_by_id).with("1").and_return(user)
        file_stub = double
        allow(FileHandler).to receive(:new).and_return(file_stub)
        allow(file_stub).to receive(:upload).with(params['attachment']).and_return('uploads/data.png')

        post = double
        allow(Post).to receive(:new).and_return(post)
        allow(post).to receive(:save)
        
        response = controller.add_post(params)
        expected_json = {
          'status' => PostView::MESSAGE[:status_ok],
          'message' => PostView::MESSAGE[:create_success]
        }.to_json

        expect(response).to eq(expected_json)
      end
    end
  end

  describe '#get_post_by_hashtag_word' do
    context 'when given valid params' do
      it 'should return right response' do
        controller = PostController.new
        post = double
        user = double
        allow(user).to receive(:to_hash).and_return({
          'id' => 1,
          'username' => 'merygorund',
          'email' => 'mery@go.round',
          'bio' => 'A ruby lover'
        })
        allow(Post).to receive(:find_by_hashtag_word).and_return([post])
        allow(post).to receive(:to_hash).and_return({
          'id' =>1,
          'content' => "Hai semuanya #ootd",
          'user' => user.to_hash,
          'attachment' => 'data/file.png'
        })

        response = controller.get_post_by_hashtag('#ootd')
        expected_json = response ={
          'status' => PostView::MESSAGE[:status_ok],
          'message' => PostView::MESSAGE[:get_success] ,
          'data' => [post.to_hash]
        }.to_json

        expect(response).to eq(expected_json)
      end
    end
  end

end