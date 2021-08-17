require_relative '../../db/db_connector'
require_relative '../../models/user'

describe User do
  before [:each] do
    client = create_db_client
    client.query("SET FOREIGN_KEY_CHECKS = 0")
    client.query("TRUNCATE TABLE users")
    client.query("SET FOREIGN_KEY_CHECKS =1")
    client.close
  end  

  describe '#username_valid?' do
    context 'when initialized with valid input' do
      it 'should return true' do
        user = User.new({
          username: "merygoround",
          email: "mery.go@gmail.com"
        })
        expect(user.username_valid?).to be true
      end
    end

    context 'when initialized with invalid input' do
      it 'should return true' do
        user = User.new({
          username: " ",
          email: "mery.go@gmail.com"
        })
        expect(user.username_valid?).to be false
      end
    end
  end

  describe '#email_valid?' do
    context 'when initialized with valid email' do
      it 'should return true' do
        user = User.new({
          username: "merygoround",
          email: "mery.go@gmail.com"
        })
        expect(user.email_valid?).to be true
      end
    end

    context 'when initialized with invalid email' do
      it 'should return false' do
        user = User.new({
          username: "merysoround",
          email: "mapwe"
        })

        expect(user.email_valid?).to be false
      end
    end

    context 'when initialized with empty email' do
      it 'should return false' do
        user = User.new({
          username: "merygoround",
          email: " "
        })

        expect(user.email_valid?).to be false
      end
    end
  end

  describe '#username_unique' do
    context 'when initialized with unique values' do
      it 'should return true' do
        user = User.new({
          username: "merygoround",
          email: "mery.go@gmail.com"
        })
        expect(user.username_unique?).to be true
      end
    end

    context 'when initialized with duplicate data' do
      it 'should return false' do
        user = User.new({
          username: "merygoround",
          email: "mery.go@gmail.com"
        })

        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        stub_query ="SELECT COUNT(id) as count FROM users WHERE username = 'merygoround'"
        allow(stub_client).to receive(:query).with(stub_query).and_return([{"count" => 1}])
        allow(stub_client).to receive(:close)
        expect(user.username_unique?).to be false
      end
    end
  end

  describe '#email_unique?' do
    context 'when initialized with unique email' do
      it 'should return true' do
        user = User.new({
          username: "merygoround",
          email: "mery.go@gmail.com"
        })
        expect(user.email_unique?).to be true
      end
    end

    context 'when initialized with duplicate email' do
      it 'should return false' do
        user = User.new({
          username: "merygoround",
          email: "mery.go@gmail.com"
        })

        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        stub_query ="SELECT COUNT(id) as count FROM users WHERE email = 'mery.go@gmail.com'"
        allow(stub_client).to receive(:query).with(stub_query).and_return([{"count" => 1}])
        allow(stub_client).to receive(:close)
        expect(user.email_unique?).to be false
      end
    end
  end

  describe '#save' do
    context 'when save non unique username' do
      it 'should return error with Message "Duplicate Username"' do
        user = User.new({
          username: 'merygoround',
          email: 'mery@go.round',
          bio: 'A ruby lover || a musician'
        })

        user.save

        expect{user.save}.to raise_error(RuntimeError, "Duplicate Username")
      end
    end

    context 'when save non unique email' do
      it 'should return error with Message "Duplicate Email"' do
        user = User.new({
          username: 'merygoround',
          email: 'mery@go.round',
          bio: 'A ruby lover || a musician'
        })

        user.save

        user = User.new({
          username: 'merygorounds',
          email: 'mery@go.round',
          bio: 'A ruby lover || a musician'
        })

        expect{user.save}.to raise_error(RuntimeError, "Duplicate Email")
      end
    end

    context 'when save invalid username' do
      it 'should return error with Message "Invalid Username"' do
        user = User.new({
          username: ' ',
          email: 'mery@go.round',
          bio: 'A ruby lover || a musician'
        })
        expect{user.save}.to raise_error(RuntimeError, "Invalid Username")
      end
    end

    context 'when save invalid email' do
      it 'should return error with Message "Invalid Email"' do
        user = User.new({
          username: 'merygoround',
          email: '',
          bio: 'A ruby lover || a musician'
        })
        expect{user.save}.to raise_error(RuntimeError, "Invalid Email")
      end
    end

    context 'when save valid object' do
      it 'should succesfully run insert query' do
        user = User.new({
          username: 'merygoround',
          email: 'mery@go.round',
          bio: 'A ruby lover || a musician'
        })

        stub_query ="INSERT INTO users (username,email,bio) VALUES ('merygoround','mery@go.round','A ruby lover || a musician')"
        username_val_query="SELECT COUNT(id) as count FROM users WHERE username = 'merygoround'"
        email_val_query = "SELECT COUNT(id) as count FROM users WHERE email = 'mery@go.round'"
        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        allow(stub_client).to receive(:query).with(username_val_query).and_return([{"count" => 0}])
        allow(stub_client).to receive(:query).with(email_val_query).and_return([{"count" => 0}])
        expect(stub_client).to receive(:query).with(stub_query)
        allow(stub_client).to receive(:close)

        user.save
      end
    end
  end
  
  describe '#find_by_id' do
    context 'when find non existent object' do
      it 'should return nil' do
        user = User.find_by_id(1)
        expect(user).to be_nil
      end
    end

    context 'when find exist object' do
      it 'should return right object' do
        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        stub_query ="SELECT * FROM users WHERE id= 1"
        
        stub_raw_data= [{
            'id' => 1,
            'username'  => 'merygoround',
            'email'  => 'mery@go.round',
            'bio'  => 'A coder'
        }]

        allow(stub_client).to receive(:query).with(stub_query).and_return(stub_raw_data)
        allow(stub_client).to receive(:close)

        user = User.find_by_id(1)

        expect(user.id).to eq(1)
        expect(user.username).to eq('merygoround')
        expect(user.email).to eq('mery@go.round')
        expect(user.bio).to eq('A coder')
      end
    end
  end
  
  describe '#find_all' do
    context 'when no user at all' do
      it 'should return nil' do
        user = User.find_all
        expect(user).to be_nil
      end
    end

    context 'when there is two users' do
      it 'should return correct array' do
        stub_client = double
        allow(Mysql2::Client).to receive(:new).and_return(stub_client)
        stub_query ="SELECT * FROM users"
        
        stub_raw_data= [{
            'id' => 1,
            'username'  => 'merygoround',
            'email'  => 'mery@go.round',
            'bio'  => 'A coder'
        },{
            'id' => 2,
            'username'  => 'merygocube',
            'email'  => 'mery@go.cube',
            'bio'  => 'A coder'
        }]

        allow(stub_client).to receive(:query).with(stub_query).and_return(stub_raw_data)
        allow(stub_client).to receive(:close)

        users = User.find_all

        expect(users.size).to eq(2)
        expect(users[0].id).to eq(1)
        expect(users[1].id).to eq(2)
      end
    end
  end

end