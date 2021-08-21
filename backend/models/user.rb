# frozen_string_literal: true

require_relative '../db/db_connector'
require_relative '../exception/user_error'

class User
  attr_reader :id, :username, :email
  attr_accessor :posts, :bio

  def initialize(param)
    @id = param[:id] ? param[:id] : nil
    @username = param[:username]
    @email = param[:email]
    @bio = param[:bio] || ''
    @posts = param[:posts] || []
  end

  def save
    raise_error_if_invalid

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

    return nil if raw_data.count.zero?

    data = raw_data.first
    User.new({
               id: data['id'],
               username: data['username'],
               email: data['email'],
               bio: data['bio']
             })
  end

  def self.find_by_username(username)
    client = create_db_client
    query = "SELECT * FROM users WHERE username = '#{username}'"
    raw_data = client.query(query)
    client.close

    return nil if raw_data.count.zero?

    data = raw_data.first
    User.new({
               id: data['id'],
               username: data['username'],
               email: data['email'],
               bio: data['bio']
             })
  end

  def self.find_all
    client = create_db_client
    query = 'SELECT * FROM users'
    raw_data = client.query(query)
    client.close

    return [] if raw_data.count.zero?

    users = []
    raw_data.each do |data|
      user = User.new({
                        id: data['id'],
                        username: data['username'],
                        email: data['email'],
                        bio: data['bio']
                      })
      users.push(user)
    end
    users
  end

  def to_hash
    raise InvalidUsername unless username_valid?
    raise InvalidEmail unless email_valid?

    {
      'id' => @id,
      'username' => @username,
      'email' => @email,
      'bio' => @bio
    }
  end


  def username_valid?
    return false if @username.nil? || @username.gsub(/\s+/, '') == ''

    true
  end

  def email_valid?
    return false if @email.nil? || !!(@email !~ URI::MailTo::EMAIL_REGEXP)

    true
  end

  def username_unique?
    client = create_db_client
    query = "SELECT COUNT(id) as count FROM users WHERE username = '#{@username}'"
    raw_data = client.query(query)
    client.close
    count = raw_data.first['count']
    count.zero?
  end

  def email_unique?
    client = create_db_client
    query = "SELECT COUNT(id) as count FROM users WHERE email = '#{@email}'"
    raw_data = client.query(query)
    client.close
    count = raw_data.first['count']
    count.zero?
  end

  def raise_error_if_invalid
    raise InvalidUsername unless username_valid?
    raise InvalidEmail unless email_valid?
    raise DuplicateUsername unless username_unique?
    raise DuplicateEmail unless email_unique?
  end
end
