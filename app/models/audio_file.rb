class AudioFile < ActiveRecord::Base
  before_validation :save_file
  before_destroy :delete_files

  has_one :annotation
  has_one :response


  def file=(file_io)
    @file = file_io
  end

  def filename(extension = 'ogg')
    id.to_s + '.' + extension
  end

  def path(extension = 'ogg')
    File.join(base_path, filename(extension))
  end

  # Find out associated student of this audio file
  #
  # If this is an audio file attached to a response, return the student; or if 
  # this is an audio file attached to a teacher's annotation, returns the 
  # student whose sound file was annotated.
  def associated_student
    annotation.try(:response).try(:user) || response.try(:user)
  end

  def associated_course
    annotation.try(:response).try(:assignment).try(:course) || response.try(:assignment).try(:course)
  end

  private
    def base_path
      Rails.root.join('uploads', 'audio_files')
    end

    def save_file
      unless new_record?
        Rails.logger.debug "Not a new_record, skipping save_file..."
        return
      end

      if @file.blank?
        raise "No file IO provided."
      end

      FileUtils.mkdir_p(base_path)

      # save db object first, in order to get an id
      save validate: false

      # start copying file, allowing overrides
      File.open(path('wav'), "wb") do |new_file|
        new_file.write(@file.read)
      end

      # convert to ogg vorbis using oggenc
      converter_io = IO.popen(['oggenc', '-o', path, path('wav')])
      Rails.logger.debug converter_io.readlines
      converter_io.close

      delete_wav

      if $?.exitstatus != 0
        raise "oggenc returned a non-zero value."
      end
    end

    def delete_file
      delete_wav
      delete_ogg
    end

    def delete_ogg
      FileUtils.rm(path) if File.exist?(path)
    end

    def delete_wav
      FileUtils.rm(path('wav')) if File.exist?(path('wav'))
    end

end
