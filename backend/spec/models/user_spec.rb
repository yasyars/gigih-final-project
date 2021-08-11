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
          username: "merygoround",
          email: "mery.g"
        })

        user2 = User.new({
          username: "merygoround",
          email: "mapwe"
        })

        expect(user.valid?).to be false
        expect(user2.valid?).to be false
      end
    end

    context 'when initialized with empty data' do
      it 'should return false' do
        user = User.new({
          username: " ",
          email: "mery@go.round"
        })

        user2 = User.new({
          username: " ",
          email: "mery@go.round"
        })

        expect(user.valid?).to be false
        expect(user2.valid?).to be false
      end
    end
  end
end