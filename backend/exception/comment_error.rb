class InvalidComment < ArgumentError
  def message
    "Comment cannot be blank and more than 1000 char"
  end
end