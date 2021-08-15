require_relative '../db/db_connector'

class User
  attr_reader :id, :username, :email
  attr_accessor :posts, :bio

  def initialize(param)
    @id = param[:id] ? param[:id] : nil
    @username = param[:username]
    @email = param[:email]
    @bio = param[:bio] ? param[:bio] : ""
    @posts = param[:posts] ? param[:posts] : []
  end

  def valid?
    raise "Invalid Username" if @username.nil? || @username.gsub(/\s+/, "")=="" || !username_unique?
    raise "Invalid Email"  if @email.nil? || !!(@email !~ URI::MailTo::EMAIL_REGEXP) || !email_unique?
    true
  end

  def username_unique?
    client = create_db_client
    query = "SELECT id FROM users WHERE username= '#{@username}'"
    raw_data = client.query(query)
    client.close
    return false unless raw_data.count==0
    true
  end

  def email_unique?
    client = create_db_client
    query = "SELECT id FROM users WHERE email= '#{@email}'"
    raw_data = client.query(query)
    return false unless raw_data.count == 0
    true
  end

  def save
    self.valid?
    client = create_db_client
    query = "INSERT INTO users (username,email,bio) VALUES ('#{@username}','#{@email}','#{@bio}')"
    client.query(query)
    client.close
  end

  def self.find_by_id(id)
    client = create_db_client
    query = "SELECT * FROM users WHERE id= #{id}"
    raw_data = client.query(query)
    client.close

    if raw_data.count == 0
      return nil
    end

    data = raw_data.first
    user = User.new({
      id: data['id'],
      username: data['username'],
      email: data['email'],
      bio: data['bio']
    })
    user
  end

  
end