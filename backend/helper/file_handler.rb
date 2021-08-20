class FileHandler
  PATH = 'uploads/'

  def upload(file)
    path_file = generate_new_name_if_exist(file)
    File.open(path_file, "w") do |f|
      f.write(file[:tempfile].read)
    end
    return path_file
  end

  def generate_new_name_if_exist(file)
    path_file = PATH + file[:filename]
    i = 1
    while exist?(path_file)
      path_file = PATH + "#{i}-" + file[:filename]
      i+=1
    end
    return path_file
  end

  def exist?(path_file)
    File.file?(path_file)
  end

end