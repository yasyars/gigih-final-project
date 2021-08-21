class InvalidHashtag < ArgumentError
  def message
    "Hashtag must follow #<char_without_space> template"
  end
end