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
    return false if @username.nil? || @username.gsub(/\s+/, "")==""
    return false if @email.nil? || !!(@email !~ URI::MailTo::EMAIL_REGEXP)
    true
  end

end