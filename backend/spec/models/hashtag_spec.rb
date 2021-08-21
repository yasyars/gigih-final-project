# frozen_string_literal: true

require_relative '../../db/db_connector'
require_relative '../../exception/hashtag_error'
require_relative '../../models/hashtag'

describe Hashtag do
  before [:each] do
    client = create_db_client
    client.query('SET FOREIGN_KEY_CHECKS = 0')
    client.query('TRUNCATE TABLE hashtags')
    client.query('SET FOREIGN_KEY_CHECKS =1')
    client.close
  end

  describe '.valid?' do
    context 'when initialized with valid input' do
      it 'should return true' do
        hashtag = Hashtag.new({
                                word: '#generasigigih'
                              })
        expect(hashtag.valid?).to be true
      end
    end

    context 'when initialized with invalid format' do
      it 'should return false' do
        hashtag = Hashtag.new({
                                word: '#generasi gigih'
                              })
        hashtag2 = Hashtag.new({
                                 word: 'generasi'
                               })

        expect(hashtag.valid?).to be false
        expect(hashtag2.valid?).to be false
      end
    end

    context 'when initialized with empty word' do
      it 'should return false' do
        hashtag = Hashtag.new({
                                word: ''
                              })
        expect(hashtag.valid?).to be false
      end
    end
  end

  describe '.unique?' do
    context 'when initialized with unique values' do
      it 'should return true' do
        hashtag = Hashtag.new({
                                word: '#generasigigih'
                              })
        expect(hashtag.unique?).to be true
      end
    end

    context 'when initialized with duplicate data' do
      it 'should return false' do
        hashtag = Hashtag.new({
                                word: '#GenerasiGigih'
                              })

        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        stub_query = "SELECT COUNT(id) as count FROM hashtags WHERE word = '#generasigigih'"
        allow(stub_client).to receive(:query).with(stub_query).and_return([{ 'count' => 1 }])
        allow(stub_client).to receive(:close)
        expect(hashtag.unique?).to be false
      end
    end
  end

  describe '.save' do
    context 'when save non unique data' do
      it 'should return error with message Duplicate Data' do
        hashtag = Hashtag.new({
                                word: '#GenerasiGigih'
                              })
        hashtag.save

        expect { hashtag.save }.to raise_error(DuplicateHashtag)
      end
    end

    context 'when save invalid hashtag' do
      it 'should return error with error message Invalid Hashtag' do
        hashtag = Hashtag.new({
                                word: 'asd'
                              })
        expect { hashtag.save }.to raise_error(InvalidHashtag)
      end
    end

    context 'when save valid object' do
      it 'should succesfully run insert hashtag' do
        hashtag = Hashtag.new({
                                word: '#generasigigih'
                              })

        stub_query = "INSERT INTO hashtags (word) VALUES ('#generasigigih')"
        word_count_query = "SELECT COUNT(id) as count FROM hashtags WHERE word = '#generasigigih'"
        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        allow(stub_client).to receive(:query).with(word_count_query).and_return([{ 'count' => 0 }])
        expect(stub_client).to receive(:query).with(stub_query)
        allow(stub_client).to receive(:close)

        hashtag.save
      end
    end
  end

  describe '.save_or_find' do
    context 'when initialized with unique hashtag' do
      it 'should save hashtag' do
        hashtag = double
        allow(Hashtag).to receive(:new).and_return(hashtag)
        allow(hashtag).to receive(:unique?).and_return(true)
        allow(Hashtag).to receive(:find_by_word)

        expect(hashtag).to receive(:save)

        Hashtag.save_or_find('ootd')
      end
    end
    context 'when initialized with not unique hashtag' do
      it 'should only find hashtag' do
        hashtag = double
        allow(Hashtag).to receive(:new).and_return(hashtag)
        allow(hashtag).to receive(:unique?).and_return(false)
        allow(Hashtag).to receive(:find_by_word)

        expect(hashtag).not_to receive(:save)

        Hashtag.save_or_find('ootd')
      end
    end
  end

  describe '.find_by_id' do
    context 'when find non existent object' do
      it 'should return nil' do
        hashtag = Hashtag.find_by_id(1)
        expect(hashtag).to be_nil
      end
    end

    context 'when find exist object' do
      it 'should return right object' do
        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        stub_query = 'SELECT * FROM hashtags WHERE id= 1'

        stub_raw_data = [{
          'id' => 1,
          'word' => '#generasigigih'
        }]

        allow(stub_client).to receive(:query).with(stub_query).and_return(stub_raw_data)
        allow(stub_client).to receive(:close)

        hashtag = Hashtag.find_by_id(1)

        expect(hashtag.id).to eq(1)
        expect(hashtag.word).to eq('#generasigigih')
      end
    end
  end

  describe '.find_by_word' do
    context 'when find non existent object' do
      it 'should return nil' do
        hashtag = Hashtag.find_by_word('#nono')
        expect(hashtag).to be_nil
      end
    end

    context 'when find exist object' do
      it 'should return right object' do
        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)

        word_str = '#generasigigih'
        stub_query = "SELECT * FROM hashtags WHERE word = '#{word_str}'"

        stub_raw_data = [{
          'id' => 1,
          'word' => word_str
        }]

        allow(stub_client).to receive(:query).with(stub_query).and_return(stub_raw_data)
        allow(stub_client).to receive(:close)

        hashtag = Hashtag.find_by_word(word_str)

        expect(hashtag.id).to eq(1)
        expect(hashtag.word).to eq('#generasigigih')
      end
    end
  end

  describe '.find_trending' do
    context 'when find non existent object' do
      it 'should return empty array' do
        hashtag = Hashtag.find_trending
        expect(hashtag).to eq([])
      end
    end

    context 'when there are trending' do
      it 'should return right array' do
        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        stub_query = "SELECT hashtags.id, hashtags.word
            FROM hashtags
            JOIN (SELECT post_id, hashtag_id
            		FROM posts
            		JOIN posts_hashtags ON posts.id = posts_hashtags.post_id
            		WHERE timestamp >= NOW() - INTERVAL 1 DAY

            		UNION ALL

            		SELECT comment_id, hashtag_id
            		FROM comments
            		JOIN comments_hashtags ON comments.id = comments_hashtags.comment_id
            		WHERE timestamp >= NOW() - INTERVAL 1 DAY) as hashtag_data
            ON hashtags.id = hashtag_data.hashtag_id
            GROUP BY hashtag_id
            ORDER BY COUNT(hashtag_data.post_id) DESC
            LIMIT 5;"

        stub_raw_data = [{
          'id' => 1,
          'word' => '#generasigigih1'
        }, {
          'id' => 2,
          'word' => '#generasigigih2'
        }, {
          'id' => 3,
          'word' => '#generasigigih3'
        }, {
          'id' => 4,
          'word' => '#generasigigih4'
        }, {
          'id' => 5,
          'word' => '#generasigigih5'
        }]

        allow(stub_client).to receive(:query).with(stub_query).and_return(stub_raw_data)
        allow(stub_client).to receive(:close)

        hashtag = Hashtag.find_trending

        expect(hashtag.size).to eq(5)
      end
    end
  end

  describe '.to_hash' do
    context 'when initialized with valid object' do
      it 'should return expected map' do
        hashtag = Hashtag.new({
                                id: 1,
                                word: '#haha'
                              })

        expected_hash = {
          'id' => 1,
          'word' => '#haha'
        }

        expect(hashtag.to_hash).to eq(expected_hash)
      end
    end
  end
end
