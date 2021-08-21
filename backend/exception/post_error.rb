class PostNotFound < ArgumentError
  def message
    "Post has not been created"
  end
end

class InvalidPost < ArgumentError
  def message
    "Post cannot be blank and more than 1000 char"
  end
end