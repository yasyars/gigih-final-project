# frozen_string_literal: true

require 'dotenv/load'
require_relative '../../db/db_connector'
require_relative '../../controllers/hashtag_controller'
require_relative '../../views/hashtag_view'
require 'json'

describe HashtagController do
  before [:each] do
    client = create_db_client
    client.query('SET FOREIGN_KEY_CHECKS = 0')
    client.query('TRUNCATE TABLE hashtags')
    client.query('SET FOREIGN_KEY_CHECKS =1')
    client.close
  end

  describe '.get_trending' do
    let(:controller) { HashtagController.new }
    let(:response) { controller.get_trending }

    context 'when there is no hashtag' do
      it 'should return success response with empty array data' do
        allow(Hashtag).to receive(:find_trending).and_return([])
        expected = {
          'status' => HashtagView::MESSAGE[:status_ok],
          'message' => HashtagView::MESSAGE[:get_not_found],
          'data' => []
        }.to_json
        expect(response).to eq(expected)
      end
    end
    
    context 'when there are some hashtags' do
      it 'should return success response with right message' do
        hashtags = [{
          'id': '1',
          'word': '#ootd'
        }]
        allow(Hashtag).to receive(:find_trending).and_return(hashtags)
        controller = HashtagController.new
        response = controller.get_trending

        expected = {
          'status'=> HashtagView::MESSAGE[:status_ok],
          'message'=> HashtagView::MESSAGE[:get_success],
          'data'=> hashtags.map(&:to_hash)
        }.to_json

        expect(response).to eq(expected)
      end
    end
  end
end
