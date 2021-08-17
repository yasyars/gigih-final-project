require_relative '../../db/db_connector'
require_relative '../../models/post'

describe Post do
  before [:each] do
    client = create_db_client
    client.query("SET FOREIGN_KEY_CHECKS = 0")
    client.query("TRUNCATE TABLE posts")
    client.query("SET FOREIGN_KEY_CHECKS =1")
    client.close
  end  

  describe '#valid?' do
    context 'when initialized with <1000 char' do
      it 'should return true' do
        user = double

        post = Post.new({
          content: "Hai semua, selamat pagi semoga harimu menyenangkan #sunshine",
          user: user
        })

        expect(post.valid?).to be true
      end
    end

    context 'when initialized with 1000 char' do
      it 'should return true' do
        user = double

        post = Post.new({
          content: "Lorem ipsum dolor sit amet, consectetur adipiscLorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ante magna, gravida at porta sed, interdum quis tellus. Proin finibus iaculis ipsum, nec eleifend nibh condimentum ac. Aliquam luctus rhoncus facilisis. Phasellus molestie odio feugiat odio aliquam facilisis. Aliquam convallis arcu sed pulvinar rhoncus. Vivamus a suscipit sem. Nunc vel mi sed orci lacinia aliquet et vel mi. Nulla vulputate rhoncus metus, vitae venenatis est. Nunc enim nunc, congue sed arcu id, sollicitudin luctus purus. Curabitur a nibh eget risus convallis pulvinar. Nunc dignissim ex sed massa pharetra, sed pellentesque tellus auctor. Phasellus dictum eget turpis ut consectetur. Ut risus lectus, dignissim eget ex quis, lobortis sagittis nibh. Duis tempus purus lorem. Morbi nisi lorem, volutpat nec hendrerit ut, suscipit at tortor. Maecenas at sem placerat, sollicitudin lacus eget, volutpat nunc. Donec sagittis magna eget ante sagittis, eget ornare nisi iaculis.",
          user: user
        })

        expect(post.valid?).to be true
      end
    end

    context 'when initialized with >1000 char' do
      it 'should return false' do
        user = double

        post = Post.new({
          content: "Lorem ipsum dolor sit amet, consectetur adipiscLorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ante magna, gravida at porta sed, interdum quis tellus. Proin finibus iaculis ipsum, nec eleifend nibh condimentum ac. Aliquam luctus rhoncus facilisis. Phasellus molestie odio feugiat odio aliquam facilisis. Aliquam convallis arcu sed pulvinar rhoncus. Vivamus a suscipit sem. Nunc vel mi sed orci lacinia aliquet et vel mi. Nulla vulputate rhoncus metus, vitae venenatis est. Nunc enim nunc, congue sed arcu id, sollicitudin luctus purus. Curabitur a nibh eget risus convallis pulvinar. Nunc dignissim ex sed massa pharetra, sed pellentesque tellus auctor. Phasellus dictum eget turpis ut consectetur. Ut risus lectus, dignissim eget ex quis, lobortis sagittis nibh. Duis tempus purus lorem. Morbi nisi lorem, volutpat nec hendrerit ut, suscipit at tortor. Maecenas at sem placerat, sollicitudin lacus eget, volutpat nunc. Donec sagittis magna eget ante sagittis, eget ornare nisi iaculis. Suspendisse potenti. In vitae ligula at nulla pharetra dictum. In vestibulum at libero in tincidunt. Etiam congue ornare diam, quis mollis velit mollis vel. Proin rutrum id nunc sit amet rhoncus.",
          user: user
        })

        expect(post.valid?).to be false
      end
    end
  end

  describe '#extract_hashtag' do
    context 'when initialized with no hashtag' do
      it 'should return empty array' do
        user = double

        post = Post.new({
          content: "Hai semua, selamat pagi semoga harimu menyenangkan",
          user: user
        })

        expect(post.extract_hashtag).to eq([])
      end
    end

    context 'when initialized with a hashtag' do
      it 'should return array with a member' do
        user = double

        post = Post.new({
          content: "Hai semuanya, bagus gak pakaianku? #ootd",
          user: user
        })

        expect(post.extract_hashtag).to eq(['#ootd'])
      end
    end

    context 'when initialized with 2 same hashtag' do
      it 'should return array with one member' do
        user = double

        post = Post.new({
          content: "Hai semuanya, bagus gak pakaianku? #ootd #oOtD",
          user: user
        })

        expect(post.extract_hashtag).to eq(['#ootd'])
      end
    end

    context 'when initialized with 2 different hashtag' do
      it 'should return array with 2 members' do
        user = double

        post = Post.new({
          content: "Hai semuanya, bagus gak pakaianku? #ootd #sunday",
          user: user
        })

        expect(post.extract_hashtag).to eq(['#ootd','#sunday'])
      end
    end
  end
end