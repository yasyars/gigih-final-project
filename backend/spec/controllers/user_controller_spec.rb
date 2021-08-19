require_relative '../../db/db_connector'
require_relative '../../controllers/user_controller'
require 'json'

describe UserController do
  before [:each] do
    client = create_db_client
    client.query("SET FOREIGN_KEY_CHECKS = 0")
    client.query("TRUNCATE TABLE users")
    client.query("SET FOREIGN_KEY_CHECKS =1")
    client.close
  end  
  
  describe '#register' do
    context 'when given valid params' do
      it 'should return right response' do
        controller = UserController.new
        username_str = '@merygoround'
        email_str = 'mery@go.round'
        bio_str = 'A ruby lover'
        params = {
          'username' => username_str,
          'email' => email_str,
          'bio' => bio_str
        }

        response = controller.register(params)
        expected_json = {
          'message' => 'User successfully created'
        }.to_json

        expect(response).to eq(expected_json)
      end
    end
  end
end