require_relative '../db/db_connector'

class User
  attr_reader :id, :username, :email
  attr_accessor :posts, :bio

  def initialize(param)
    @id = param[:id]
    @username = param[:username]
    @email = param[:email]
    @bio = param[:bio]
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
    return false unless raw_data.each.empty?
    true
  end

  def email_unique?
    client = create_db_client
    query = "SELECT id FROM users WHERE email= '#{@email}'"
    raw_data = client.query(query)
    return false unless raw_data.each.empty?
    true
  end

end