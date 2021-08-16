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
end