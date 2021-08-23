# frozen_string_literal: true

class FileHandler
  PATH = 'uploads/'

  def upload(file)
    path_file = generate_new_name_if_exist(file)
    File.open(path_file, 'w') do |f|
      f.write(file[:tempfile].read)
    end
    path_file
  end

  def generate_new_name_if_exist(file)
    begin
      file_name = file[:filename].gsub(/\s+/, '')
    rescue
      raise TypeError,"Attachment type is not valid, make sure it is a png, jpg, txt, or other types of file"
    end
    path_file = PATH + file_name
    i = 1
    while exist?(path_file)
      path_file = PATH + "#{i}-" + file_name
      i += 1
    end
    path_file
  end

  def exist?(path_file)
    File.file?(path_file)
  end
end
