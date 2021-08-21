class UserNotFound < ArgumentError;
  def message
    "User has not been created"
  end
end

class PostNotFound < ArgumentError;
  def message
    "Post has not been created"
  end
end

class InvalidComment < ArgumentError;
  def message
    "Comment cannot be blank and more than 1000 char"
  end
end

class InvalidPost < ArgumentError;
  def message
    "Post cannot be blank and more than 1000 char"
  end
end

class InvalidHashtag < ArgumentError;
  def message
    "Hashtag must follow #<char_without_space> template"
  end
end