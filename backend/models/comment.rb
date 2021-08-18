require_relative '../db/db_connector'
require_relative 'post'

class Comment < Post

  def initialize(param)
    super(param)
    @user = param[:user]
  end

end