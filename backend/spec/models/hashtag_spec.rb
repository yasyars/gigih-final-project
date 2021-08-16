require_relative '../../db/db_connector'
require_relative '../../models/hashtag'


describe Hashtag do
  before [:each] do
    client = create_db_client
    client.query("SET FOREIGN_KEY_CHECKS = 0")
    client.query("TRUNCATE TABLE hashtags")
    client.query("SET FOREIGN_KEY_CHECKS =1")
    client.close
  end  

  describe '#valid?' do
    context 'when initialized with valid input' do
      it 'should return true' do
        hashtag = Hashtag.new({
          word: "#generasigigih"
        })
        expect(hashtag.valid?).to be true
      end
    end

    context 'when initialized with invalid format' do
      it 'should return false' do
        hashtag = Hashtag.new({
          word: "#generasi gigih"
        })
        hashtag2 = Hashtag.new({
          word: "generasi"
        })
        
        expect(hashtag.valid?).to be false
        expect(hashtag2.valid?).to be false
      end
    end

    context 'when initialized with empty word' do
      it 'should return false' do
        hashtag = Hashtag.new({
          word: "",
        })
        expect(hashtag.valid?).to be false
      end
    end
  end

  describe '#unique?' do
    context 'when initialized with unique values' do
      it 'should return true' do
        hashtag = Hashtag.new({
          word: "#generasigigih"
        })
        expect(hashtag.unique?).to be true
      end
    end

    context 'when initialized with duplicate data' do
      it 'should return false' do
        hashtag = Hashtag.new({
          word: "#GenerasiGigih"
        })

        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        stub_query ="SELECT COUNT(id) as count FROM hashtags WHERE word = '#generasigigih'"
        allow(stub_client).to receive(:query).with(stub_query).and_return([{"count" => 1}])
        allow(stub_client).to receive(:close)
        expect(hashtag.unique?).to be false
      end
    end
  end

  
end