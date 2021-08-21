class UserNotFound < ArgumentError
  def message
    "User has not been created"
  end
end

class InvalidUsername < ArgumentError
  def message
    "Username can not be blank"
  end
end

class InvalidEmail < ArgumentError
  def message
    "Email doesn't match the format"
  end
end

class DuplicateUsername < ArgumentError
  def message
    "Username is taken"
  end
end

class DuplicateEmail < ArgumentError
  def message
    "Email is taken"
  end
end
