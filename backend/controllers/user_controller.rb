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
end