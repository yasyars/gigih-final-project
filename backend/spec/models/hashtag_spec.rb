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
  
  describe '#save' do
    context 'when save non unique data' do
      it 'should return error with message Duplicate Data' do
        hashtag = Hashtag.new({
          word: '#GenerasiGigih'          
        })
        hashtag.save

        expect{hashtag.save}.to raise_error(RuntimeError, "Duplicate Data")
      end
    end

    context 'when save invalid hashtag' do
      it 'should return error with error message Invalid Hashtag' do
        hashtag = Hashtag.new({
          word: "asd"
        })
        expect{hashtag.save}.to raise_error(RuntimeError, "Invalid Hashtag")
      end
    end

    context 'when save valid object' do
      it 'should succesfully run insert hashtag' do
        hashtag = Hashtag.new({
          word: '#generasigigih'
        })
      
        stub_query ="INSERT INTO hashtags (word) VALUES ('#generasigigih')"
        word_count_query="SELECT COUNT(id) as count FROM hashtags WHERE word = '#generasigigih'"
        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        allow(stub_client).to receive(:query).with(word_count_query).and_return([{"count" => 0}])
        expect(stub_client).to receive(:query).with(stub_query)
        allow(stub_client).to receive(:close)

        hashtag.save
      end
    end
  end

  # describe '#find_by_id' do
  #   context 'when find non existent object' do
  #     it 'should return nil' do
  #       user = User.find_by_id(1)
  #       expect(user).to be_nil
  #     end
  #   end

  #   context 'when find exist object' do
  #     it 'should return right object' do
  #       stub_client = double
  #       allow(Mysql2::Client).to receive(:new).and_return(stub_client)
  #       stub_query ="SELECT * FROM users WHERE id= 1"
        
  #       stub_raw_data= [{
  #           'id' => 1,
  #           'username'  => 'merygoround',
  #           'email'  => 'mery@go.round',
  #           'bio'  => 'A coder'
  #       }]

  #       allow(stub_client).to receive(:query).with(stub_query).and_return(stub_raw_data)
  #       allow(stub_client).to receive(:close)

  #       user = User.find_by_id(1)

  #       expect(user.id).to eq(1)
  #       expect(user.username).to eq('merygoround')
  #       expect(user.email).to eq('mery@go.round')
  #       expect(user.bio).to eq('A coder')
  #     end
  #   end
  # end
  
  # describe '#find_all' do
  #   context 'when no user at all' do
  #     it 'should return nil' do
  #       user = User.find_all
  #       expect(user).to be_nil
  #     end
  #   end

  #   context 'when there is two users' do
  #     it 'should return correct array' do
  #       stub_client = double
  #       allow(Mysql2::Client).to receive(:new).and_return(stub_client)
  #       stub_query ="SELECT * FROM users"
        
  #       stub_raw_data= [{
  #           'id' => 1,
  #           'username'  => 'merygoround',
  #           'email'  => 'mery@go.round',
  #           'bio'  => 'A coder'
  #       },{
  #           'id' => 2,
  #           'username'  => 'merygocube',
  #           'email'  => 'mery@go.cube',
  #           'bio'  => 'A coder'
  #       }]

  #       allow(stub_client).to receive(:query).with(stub_query).and_return(stub_raw_data)
  #       allow(stub_client).to receive(:close)

  #       users = User.find_all

  #       expect(users.size).to eq(2)
  #       expect(users[0].id).to eq(1)
  #       expect(users[1].id).to eq(2)
  #     end
  #   end
  # end
  
end