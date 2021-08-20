require_relative '../../db/db_connector'
require_relative '../../models/comment'
require_relative '../../models/post'
require_relative '../../models/user'

describe Comment do
  before [:each] do
    client = create_db_client
    client.query("SET FOREIGN_KEY_CHECKS = 0")
    client.query("TRUNCATE TABLE comments")
    client.query("TRUNCATE TABLE comments_hashtags")
    client.query("SET FOREIGN_KEY_CHECKS =1")
    client.close
  end  

  describe '#valid?' do
    context 'when initialized with space only' do
      it 'should return false' do
        user = double
        post = double

        comment = Comment.new({
          content: "     ",
          user: user,
          post: post
        })

        expect(comment.valid?).to be false
      end
    end
    context 'when initialized with 0<char<1000' do
      it 'should return true' do
        user = double
        post = double

        comment = Comment.new({
          content: "Hai semua, selamat pagi semoga harimu menyenangkan #sunshine",
          user: user,
          post: post
        })

        expect(comment.valid?).to be true
      end
    end

    context 'when initialized with 1000 char' do
      it 'should return true' do
        user = double
        post = double

       comment = Comment.new({
          content: "Lorem ipsum dolor sit amet, consectetur adipiscLorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ante magna, gravida at porta sed, interdum quis tellus. Proin finibus iaculis ipsum, nec eleifend nibh condimentum ac. Aliquam luctus rhoncus facilisis. Phasellus molestie odio feugiat odio aliquam facilisis. Aliquam convallis arcu sed pulvinar rhoncus. Vivamus a suscipit sem. Nunc vel mi sed orci lacinia aliquet et vel mi. Nulla vulputate rhoncus metus, vitae venenatis est. Nunc enim nunc, congue sed arcu id, sollicitudin luctus purus. Curabitur a nibh eget risus convallis pulvinar. Nunc dignissim ex sed massa pharetra, sed pellentesque tellus auctor. Phasellus dictum eget turpis ut consectetur. Ut risus lectus, dignissim eget ex quis, lobortis sagittis nibh. Duis tempus purus lorem. Morbi nisi lorem, volutpat nec hendrerit ut, suscipit at tortor. Maecenas at sem placerat, sollicitudin lacus eget, volutpat nunc. Donec sagittis magna eget ante sagittis, eget ornare nisi iaculis.",
          user: user,
          post: post
        })

        expect(comment.valid?).to be true
      end
    end

    context 'when initialized with >1000 char' do
      it 'should return false' do
        user = double
        post = double

        comment = Comment.new({
          content: "Lorem ipsum dolor sit amet, consectetur adipiscLorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ante magna, gravida at porta sed, interdum quis tellus. Proin finibus iaculis ipsum, nec eleifend nibh condimentum ac. Aliquam luctus rhoncus facilisis. Phasellus molestie odio feugiat odio aliquam facilisis. Aliquam convallis arcu sed pulvinar rhoncus. Vivamus a suscipit sem. Nunc vel mi sed orci lacinia aliquet et vel mi. Nulla vulputate rhoncus metus, vitae venenatis est. Nunc enim nunc, congue sed arcu id, sollicitudin luctus purus. Curabitur a nibh eget risus convallis pulvinar. Nunc dignissim ex sed massa pharetra, sed pellentesque tellus auctor. Phasellus dictum eget turpis ut consectetur. Ut risus lectus, dignissim eget ex quis, lobortis sagittis nibh. Duis tempus purus lorem. Morbi nisi lorem, volutpat nec hendrerit ut, suscipit at tortor. Maecenas at sem placerat, sollicitudin lacus eget, volutpat nunc. Donec sagittis magna eget ante sagittis, eget ornare nisi iaculis. Suspendisse potenti. In vitae ligula at nulla pharetra dictum. In vestibulum at libero in tincidunt. Etiam congue ornare diam, quis mollis velit mollis vel. Proin rutrum id nunc sit amet rhoncus.",
          user: user,
          post: post
        })

        expect(comment.valid?).to be false
      end
    end
  end

  describe '#extract_hashtag' do
    context 'when initialized with no hashtag' do
      it 'should return empty array' do
        user = double
        post =double

        comment = Comment.new({
          content: "Hai semua, selamat pagi semoga harimu menyenangkan",
          user: user,
          post: post
        })

        expect(comment.extract_hashtag).to eq([])
      end
    end

    context 'when initialized with a hashtag' do
      it 'should return array with a member' do
        user = double
        post =double

        comment = Comment.new({
          content: "Hai semuanya, bagus gak pakaianku? #ootd",
          user: user,
          post: post
        })

        expect(comment.extract_hashtag).to eq(['#ootd'])
      end
    end

    context 'when initialized with 2 same hashtag' do
      it 'should return array with one member' do
        user = double
        post = double

        comment = Comment.new({
          content: "Hai semuanya, bagus gak pakaianku? #ootd #oOtD",
          user: user,
          post: post
        })

        expect(comment.extract_hashtag).to eq(['#ootd'])
      end
    end

    context 'when initialized with 2 different hashtag' do
      it 'should return array with 2 members' do
        user = double
        post = double

        comment = Comment.new({
          content: "Hai semuanya, bagus gak pakaianku? #ootd #sunday",
          user: user,
          post: post
        })

        expect(comment.extract_hashtag).to eq(['#ootd','#sunday'])
      end
    end
  end

  describe '#save' do
    before(:each) do
      @user = double
      @content_str = "Hai semuanya, bagus gak pakaianku?"
      @attachment_str = "../upload/post123.jpg"
      @post = double
      @comment = Comment.new({
        content: @content_str,
        user: @user,
        post: @post,
        attachment: @attachment_str
      })

      allow(@user).to receive(:id).and_return(1)
      allow(@post).to receive(:id).and_return(1)

      @stub_client = double
      allow(Mysql2::Client).to receive(:new).and_return(@stub_client)
      allow(@stub_client).to receive(:close)
      @stub_query = "INSERT INTO comments (content, user_id, post_id, attachment) VALUES ('#{@content_str}', #{@user.id}, #{@post.id}, '#{@attachment_str}')"
      allow(@stub_client).to receive(:last_id).and_return(1)
    end

    context 'when save with no hashtag' do
      it 'should succesfully save object' do   
        expect(@stub_client).to receive(:query).with(@stub_query)
        @comment.save
      end
    end

    context 'when save with hashtag' do
      it 'should succesfully save object' do
        expect(@stub_client).to receive(:query).with(@stub_query)
        expect(@comment).to receive(:save_with_hashtags)
        @comment.save
      end
    end

    context 'when save invalid object' do
      it 'should fail to save object' do
        comment = Comment.new({
          content: " ",
          user: @user,
          post: @post,
          attachment: @attachment_str
        })

        expect{comment.save}.to raise_error(ArgumentError,"Invalid Comment")
      end
    end
  end

  describe '#save_with_hashtags' do
    context 'when save post with a hashtag' do
      it 'should sucessfully insert posts with hashtags' do
        user = double
        post = double
        comment = Comment.new({
          id: 1,
          content: "#ootd",
          user: user,
          post: post,
          attachment:  "../upload/post123.jpg"
        })
        
        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        
        hashtag = double
        allow(hashtag).to receive(:id).and_return(1)
        allow(Hashtag).to receive(:save_or_find).with('#ootd').and_return(hashtag)
        
        stub_query ="INSERT INTO comments_hashtags (comment_id, hashtag_id) VALUES (1,1)"
        expect(stub_client).to receive(:query).with(stub_query)
        allow(stub_client).to receive(:close)

        comment.save_with_hashtags
      end
    end
  end

  describe '#find_by_hashtag_word' do
    context 'when there is no comment that matches' do
      it 'should return empty array' do
        res = Comment.find_by_hashtag_word('#ootd')
        expect(res).to eq([])
      end
    end

    context 'when there are comments that match' do
      it 'should return array with members' do
        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        stub_query = "SELECT * FROM comments JOIN comments_hashtags ON comments.id = comments_hashtags.comment_id JOIN hashtags ON comments_hashtags.hashtag_id = hashtags.id WHERE hashtags.word= '#ootd'"
        stub_raw_data_comment = [{
          'id' => 1,
          'content' => "#ootd yey",
          'user_id' => 1,
          'post_id' => 1,
          'attachment' => nil,
          'timestamp' => '2021-08-18 01:08:44'
        },{
          'id' => 2,
          'content' => "#ootd asik",
          'user_id' => 1,
          'post_id' => 1,
          'attachment' => nil,
          'timestamp' => '2021-08-18 01:08:44'
        }]

        user = double
        post = double

        allow(stub_client).to receive(:query).with(stub_query).and_return(stub_raw_data_comment)
        allow(User).to receive(:find_by_id).and_return(user)
        allow(Post).to receive(:find_by_id).and_return(post)

        allow(stub_client).to receive(:close)
        
        res = Comment.find_by_hashtag_word('#ootd')
        expect(res.size).to eq(2)
      end
    end
  end

  describe '#find_by_id' do
    context 'when there is no post that matches' do
      it 'should return empty array' do
        res = Comment.find_by_id(1)
        expect(res).to eq([])
      end
    end

    context 'when there is posts that match' do
      it 'should return array with members' do
        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        stub_query = "SELECT * FROM comments WHERE id = 1"
        stub_raw_data_post = [{
          'id' => 1,
          'content' => "#ootd yey",
          'user_id' => 1,
          'post_id' => 1,
          'attachment' => nil,
          'timestamp' => '2021-08-18 01:08:44'
        },{
          'id' => 2,
          'content' => "#ootd asik",
          'user_id' => 1,
          'post_id' => 1,
          'attachment' => nil,
          'timestamp' => '2021-08-18 01:08:44'
        }]

        user = double
        post = double
        allow(stub_client).to receive(:query).with(stub_query).and_return(stub_raw_data_post)
        allow(User).to receive(:find_by_id).and_return(user)
        allow(Post).to receive(:find_by_id).and_return(post)

        allow(stub_client).to receive(:close)
        
        res = Comment.find_by_id(1)
        expect(res.size).to eq(2)
      end
    end
  end

  describe '#to_hash' do
    context 'when initialized with valid object' do
      it 'should return expected map' do
        user = double
        post = double
        allow(user).to receive(:to_hash).and_return({})
        allow(post).to receive(:to_hash).and_return({})

        comment = Comment.new({
          id: 1,
          content: "#haha hahaha",
          user: user,
          post: post,
          attachment: "data/asset/file.png"
        })

        comment_hash = comment.to_hash
        expected_hash = {
          'id' => 1,
          'content' => "#haha hahaha",
          'user' => {},
          'post' => {},
          'attachment' => "data/asset/file.png",
          'timestamp' => nil
        }
        
        expect(comment_hash).to eq(expected_hash)
      end
    end
  end
end