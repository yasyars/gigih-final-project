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

  describe '#valid?' do
    context 'when initialized with valid input' do
      it 'should return true' do
        user = User.new({
          username: "merygoround",
          email: "mery.go@gmail.com"
        })
        expect(user.valid?).to be true
      end
    end

    context 'when initialized with invalid email' do
      it 'should return false' do
        user = User.new({
          username: "meryoround",
          email: "mery.g"
        })

        user2 = User.new({
          username: "merysoround",
          email: "mapwe"
        })

        expect{user.valid?}.to raise_error(RuntimeError,"Invalid Email")
        expect{user2.valid?}.to raise_error(RuntimeError,"Invalid Email")
      end
    end

    context 'when initialized with empty username' do
      it 'should return false' do
        user = User.new({
          username: " ",
          email: "mery@go.round"
        })

        expect{user.valid?}.to raise_error(RuntimeError,"Invalid Username")
      end
    end

    context 'when initialized with empty username' do
      it 'should return false' do
        user2 = User.new({
          username: " ",
          email: ""
        })

        expect{user2.valid?}.to raise_error(RuntimeError,"Invalid Username")
      end
    end
  end

  describe 'save' do
    context 'when save valid object' do
    end
  end
end