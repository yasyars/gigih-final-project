require_relative '../models/user'
require_relative '../views/user_view'

class UserController
  def register(params)
    response = UserView.new
    user = User.new({
      username: params['username'],
      email: params['email'],
      bio: params['bio']
    })

    user.save
    response.create_success
  end

  def get_user_by_username(params)
    response = UserView.new
    user = User.find_by_username(params['username'])
    if user.nil?
      response.empty_user
    else
      response.user_data(user)
    end
  end

end