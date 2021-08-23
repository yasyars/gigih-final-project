# frozen_string_literal: true

require 'dotenv/load'
require_relative '../../db/db_connector'
require_relative '../../controllers/user_controller'
require_relative '../../views/user_view'
require_relative '../../models/user'

require 'json'

describe UserController do

  describe '.register' do
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
        user = double
        allow(User).to receive(:new).and_return(user)
        allow(user).to receive(:save)

        response = controller.register(params)
        expected_json = {
          'status' => UserView::MESSAGE[:status_ok],
          'message' => UserView::MESSAGE[:create_success]
        }.to_json

        expect(response).to eq(expected_json)
      end
    end
  end

  describe '.get_user_by_username' do
    describe 'when given valid params' do
      let(:controller) { UserController.new }
      let(:params) do
        {
          'username' => 'merygoround'
        }
      end
      let(:response) { controller.get_user_by_username(params) }

      context 'when not found' do
        it 'should return success response with right message' do
          allow(User).to receive(:find_by_username).with('merygoround').and_return(nil)
          expected = {
            'status' => UserView::MESSAGE[:status_ok],
            'message' => UserView::MESSAGE[:get_not_found],
            'data' => nil
          }.to_json
          expect(response).to eq(expected)
        end
      end
      context 'when found' do
        it 'should return success response with right message' do
          user = double
          allow(user).to receive(:to_hash).and_return({
                                                        'id' => 1,
                                                        'username' => 'merygoround',
                                                        'email' => 'mery@go.round',
                                                        'bio' => 'A ruby lover'
                                                      })

          allow(User).to receive(:find_by_username).with('merygoround').and_return(user)

          expected = {
            'status' => UserView::MESSAGE[:status_ok],
            'message' => UserView::MESSAGE[:get_success],
            'data' => user.to_hash
          }.to_json
          expect(response).to eq(expected)
        end
      end
    end
  end
end
