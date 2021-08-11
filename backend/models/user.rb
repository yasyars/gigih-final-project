require_relative '../db/db_connector'

class User
  def initialize(param)
    @id = param[:id]
    @username = param[:username]
    @email = param[:email]
    @bio = param[:bio]
  end

  def valid?
    return false if @username.nil? || @username.gsub(/\s+/, "")==""
    return false if @email.nil? || !!(@email !~ URI::MailTo::EMAIL_REGEXP)
    true
  end

end