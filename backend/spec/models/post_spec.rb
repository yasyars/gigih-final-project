# frozen_string_literal: true

require_relative '../../db/db_connector'
require_relative '../../models/post'
require_relative '../../models/hashtag'

describe Post do
  before (:each) do
    client = create_db_client
    client.query('SET FOREIGN_KEY_CHECKS = 0')
    client.query('TRUNCATE TABLE posts')
    client.query('TRUNCATE TABLE posts_hashtags')
    client.query('SET FOREIGN_KEY_CHECKS =1')
    client.close
  end

  describe '.valid?' do
    context 'when initialized with space only' do
      it 'should return false' do
        user = double

        post = Post.new({
                          content: '     ',
                          user: user
                        })

        expect(post.valid?).to be false
      end
    end
    context 'when initialized with 0<char<1000' do
      it 'should return true' do
        user = double

        post = Post.new({
                          content: 'Hai semua, selamat pagi semoga harimu menyenangkan #sunshine',
                          user: user
                        })

        expect(post.valid?).to be true
      end
    end

    context 'when initialized with 1000 char' do
      it 'should return true' do
        user = double

        post = Post.new({
                          content: 'Lorem ipsum dolor sit amet, consectetur adipiscLorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ante magna, gravida at porta sed, interdum quis tellus. Proin finibus iaculis ipsum, nec eleifend nibh condimentum ac. Aliquam luctus rhoncus facilisis. Phasellus molestie odio feugiat odio aliquam facilisis. Aliquam convallis arcu sed pulvinar rhoncus. Vivamus a suscipit sem. Nunc vel mi sed orci lacinia aliquet et vel mi. Nulla vulputate rhoncus metus, vitae venenatis est. Nunc enim nunc, congue sed arcu id, sollicitudin luctus purus. Curabitur a nibh eget risus convallis pulvinar. Nunc dignissim ex sed massa pharetra, sed pellentesque tellus auctor. Phasellus dictum eget turpis ut consectetur. Ut risus lectus, dignissim eget ex quis, lobortis sagittis nibh. Duis tempus purus lorem. Morbi nisi lorem, volutpat nec hendrerit ut, suscipit at tortor. Maecenas at sem placerat, sollicitudin lacus eget, volutpat nunc. Donec sagittis magna eget ante sagittis, eget ornare nisi iaculis.',
                          user: user
                        })

        expect(post.valid?).to be true
      end
    end

    context 'when initialized with >1000 char' do
      it 'should return false' do
        user = double

        post = Post.new({
                          content: 'Lorem ipsum dolor sit amet, consectetur adipiscLorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ante magna, gravida at porta sed, interdum quis tellus. Proin finibus iaculis ipsum, nec eleifend nibh condimentum ac. Aliquam luctus rhoncus facilisis. Phasellus molestie odio feugiat odio aliquam facilisis. Aliquam convallis arcu sed pulvinar rhoncus. Vivamus a suscipit sem. Nunc vel mi sed orci lacinia aliquet et vel mi. Nulla vulputate rhoncus metus, vitae venenatis est. Nunc enim nunc, congue sed arcu id, sollicitudin luctus purus. Curabitur a nibh eget risus convallis pulvinar. Nunc dignissim ex sed massa pharetra, sed pellentesque tellus auctor. Phasellus dictum eget turpis ut consectetur. Ut risus lectus, dignissim eget ex quis, lobortis sagittis nibh. Duis tempus purus lorem. Morbi nisi lorem, volutpat nec hendrerit ut, suscipit at tortor. Maecenas at sem placerat, sollicitudin lacus eget, volutpat nunc. Donec sagittis magna eget ante sagittis, eget ornare nisi iaculis. Suspendisse potenti. In vitae ligula at nulla pharetra dictum. In vestibulum at libero in tincidunt. Etiam congue ornare diam, quis mollis velit mollis vel. Proin rutrum id nunc sit amet rhoncus.',
                          user: user
                        })

        expect(post.valid?).to be false
      end
    end
  end

  describe '.extract_hashtag' do
    context 'when initialized with no hashtag' do
      it 'should return empty array' do
        user = double

        post = Post.new({
                          content: 'Hai semua, selamat pagi semoga harimu menyenangkan',
                          user: user
                        })

        expect(post.extract_hashtag).to eq([])
      end
    end

    context 'when initialized with a hashtag' do
      it 'should return array with a member' do
        user = double

        post = Post.new({
                          content: 'Hai semuanya, bagus gak pakaianku? #ootd',
                          user: user
                        })

        expect(post.extract_hashtag).to eq(['#ootd'])
      end
    end

    context 'when initialized with 2 same hashtag' do
      it 'should return array with one member' do
        user = double

        post = Post.new({
                          content: 'Hai semuanya, bagus gak pakaianku? #ootd #oOtD',
                          user: user
                        })

        expect(post.extract_hashtag).to eq(['#ootd'])
      end
    end

    context 'when initialized with 2 different hashtag' do
      it 'should return array with 2 members' do
        user = double

        post = Post.new({
                          content: 'Hai semuanya, bagus gak pakaianku? #ootd #sunday',
                          user: user
                        })

        expect(post.extract_hashtag).to eq(['#ootd', '#sunday'])
      end
    end
  end

  describe '.save' do
    before [:each] do
      @user = double
      @content_str = 'Hai semuanya, bagus gak pakaianku?'
      @attachment_str = '../upload/post123.jpg'
      @post = Post.new({
                         content: @content_str,
                         user: @user,
                         attachment: @attachment_str
                       })
      allow(@user).to receive(:id).and_return(1)
      @stub_client = double
      allow(Mysql2::Client).to receive(:new).and_return(@stub_client)
      allow(@stub_client).to receive(:close)
      @stub_query = "INSERT INTO posts (content, user_id, attachment) VALUES ('#{@content_str}', #{@user.id}, '#{@attachment_str}')"
      allow(@stub_client).to receive(:last_id).and_return(1)
    end

    context 'when save with no hashtag' do
      it 'should succesfully save object' do
        expect(@stub_client).to receive(:query).with(@stub_query)
        @post.save
      end
    end

    context 'when save with hashtag' do
      it 'should succesfully save object' do
        expect(@stub_client).to receive(:query).with(@stub_query)
        expect(@post).to receive(:save_hashtags)
        @post.save
      end
    end

    context 'when save invalid object' do
      it 'should fail to save object' do
        post = Post.new({
                          content: ' ',
                          user: @user,
                          attachment: @attachment_str
                        })

        expect { post.save }.to raise_error(InvalidPost)
      end
    end
  end

  describe '.save_hashtags' do
    context 'when save post with a hashtag' do
      it 'should sucessfully insert posts with hashtags' do
        user = double
        post = Post.new({
                          id: 1,
                          content: '#ootd',
                          user: user,
                          attachment: '../upload/post123.jpg'
                        })

        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)

        hashtag = double
        allow(hashtag).to receive(:id).and_return(1)
        allow(Hashtag).to receive(:save_or_find).with('#ootd').and_return(hashtag)

        stub_query = 'INSERT INTO posts_hashtags (post_id, hashtag_id) VALUES (1,1)'
        expect(stub_client).to receive(:query).with(stub_query)
        allow(stub_client).to receive(:close)

        post.save_hashtags
      end
    end
  end

  describe '.find_all' do
    context 'when there is no post' do
      it 'should return empty array' do
        res = Post.find_all
        expect(res).to eq([])
      end
    end

    context 'when there are posts' do
      it 'should return array with members' do
        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        stub_query = 'SELECT * FROM posts'
        stub_raw_data_post = [{
          'id' => 1,
          'content' => '#ootd yey',
          'user_id' => 1,
          'attachment' => nil,
          'timestamp' => '2021-08-18 01:08:44'
        }, {
          'id' => 2,
          'content' => '#ootd asik',
          'user_id' => 1,
          'attachment' => nil,
          'timestamp' => '2021-08-18 01:08:44'
        }]

        user = double
        allow(stub_client).to receive(:query).with(stub_query).and_return(stub_raw_data_post)
        allow(User).to receive(:find_by_id).and_return(user)

        allow(stub_client).to receive(:close)

        res = Post.find_all
        expect(res.size).to eq(2)
      end
    end
  end

  describe '.find_by_id' do
    context 'when there is no post that matches' do
      it 'should return empty array' do
        res = Post.find_by_id(1)
        expect(res).to be_nil
      end
    end

    context 'when there is posts that match' do
      it 'should return right object' do
        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        stub_query = 'SELECT * FROM posts WHERE id = 1'
        stub_raw_data_post = [{
          'id' => 1,
          'content' => '#ootd yey',
          'user_id' => 1,
          'attachment' => nil,
          'timestamp' => '2021-08-18 01:08:44'
        }]

        user = double
        allow(stub_client).to receive(:query).with(stub_query).and_return(stub_raw_data_post)
        allow(User).to receive(:find_by_id).and_return(user)

        allow(stub_client).to receive(:close)

        res = Post.find_by_id(1)
        expect(res.id).to eq(1)
        expect(res.content).to eq('#ootd yey')
        expect(res.attachment).to be_nil
        expect(res.timestamp).to eq('2021-08-18 01:08:44')
      end
    end
  end

  describe '.find_by_hashtag_word' do
    context 'when there is no post that matches' do
      it 'should return empty array' do
        res = Post.find_by_hashtag_word('#ootd')
        expect(res).to eq([])
      end
    end

    context 'when there are posts that match' do
      it 'should return array with two member' do
        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        stub_query = "SELECT posts.id , posts.content , posts.user_id , posts.attachment, posts.timestamp FROM posts JOIN posts_hashtags ON posts.id = posts_hashtags.post_id JOIN hashtags ON posts_hashtags.hashtag_id = hashtags.id WHERE hashtags.word= '#ootd'"
        stub_raw_data_post = [{
          'id' => 1,
          'content' => '#ootd yey',
          'user_id' => 1,
          'attachment' => nil,
          'timestamp' => '2021-08-18 01:08:44'
        }, {
          'id' => 2,
          'content' => '#ootd asik',
          'user_id' => 1,
          'attachment' => nil,
          'timestamp' => '2021-08-18 01:08:44'
        }]

        user = double
        allow(stub_client).to receive(:query).with(stub_query).and_return(stub_raw_data_post)
        allow(User).to receive(:find_by_id).and_return(user)

        allow(stub_client).to receive(:close)

        res = Post.find_by_hashtag_word('#ootd')
        expect(res.size).to eq(2)
      end
    end
  end

  describe '.find_comment_by_hashtag_word' do
    before [:each] do
      @post = Post.new({
                         id: 1,
                         content: @content_str,
                         user: @user,
                         attachment: @attachment_str
                       })
      allow(@user).to receive(:id).and_return(1)
      @stub_client = double
      allow(Mysql2::Client).to receive(:new).and_return(@stub_client)
      allow(@stub_client).to receive(:close)
    end

    context 'when there are no result' do
      it 'should return empty array' do
        word = '#ootd'
        post_id =1
        stub_raw_data = []
        query_stub = "SELECT comments.id , comments.content , comments.post_id, comments.user_id , comments.attachment, comments.timestamp FROM comments JOIN comments_hashtags ON comments.id = comments_hashtags.comment_id JOIN hashtags ON comments_hashtags.hashtag_id = hashtags.id WHERE hashtags.word= '#{word}' AND comments.post_id = #{post_id}"
        allow(@stub_client).to receive(:query).with(query_stub).and_return(stub_raw_data)

        expect(@post.find_comment_by_hashtag_word('#ootd')).to eq([])
      end
    end
  end

  describe '.to_hash' do
    context 'when initialized with valid object' do
      it 'should return expected map' do
        user = double
        allow(user).to receive(:to_hash).and_return({})
        content_str = '#haha hahaha'
        attachment_str = 'data/asset/file.png'
        timestamp_str = '2021-08-08 01:38:00'
        post = Post.new({
                          id: 1,
                          content: content_str,
                          user: user,
                          attachment: attachment_str,
                          timestamp: timestamp_str,
                          hashtags: []
                        })

        post_hash = post.to_hash
        expected_hash = {
          'id' => 1,
          'content' => content_str,
          'user' => {},
          'attachment' => attachment_str,
          'timestamp' => timestamp_str,
          'hashtags'=> []
        }

        expect(post_hash).to eq(expected_hash)
      end
    end
  end

  describe '.set_base_url' do
    context 'when there is valid attachment' do
      it 'should concate succesfully' do
        post = Post.new({
          attachment: 'upload/file.png'
        })

        post.set_base_url('domain.com')
        expect(post.attachment).to eq('domain.com/upload/file.png')
      end
    end

    context 'when there is invalid attachment' do
      it 'should set attachment to nil' do
        post = Post.new({
          attachment: '  '
        })

        post.set_base_url('domain.com')
        expect(post.attachment).to be_nil
      end
    end
  end
end
