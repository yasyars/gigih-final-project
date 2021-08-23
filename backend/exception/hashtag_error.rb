class InvalidHashtag < ArgumentError
  def message
    "Hashtag must follow #<char_without_space> template"
  end
end

class DuplicateHashtag < ArgumentError
  def message
    "Hashtag already exists"
  end
end