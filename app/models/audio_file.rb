class AudioFile < ActiveRecord::Base
  has_one :response

  before_validation :save_file
  before_destroy :delete_file

  validate :wav_or_ogg_defined?

  # you didn't assign your file io by doing file=()
  class NoFile < StandardError; end

  def file=(file_io)
    @file = file_io
  end

  def path
    unless ogg_name.blank?
      File.join(get_base_path(), ogg_name)
    else
      File.join(get_base_path(), wav_name)
    end
  end

  def mime_type
    unless ogg_name.blank?
      "audio/opus"
    else
      "audio/wav"
    end
  end

  private
    def get_base_path()
      Rails.root.join('public', 'data')
    end

    def save_file
      # if ogg file already exists, return directly since we don't need WAVE anymore
      if not self.ogg_name.blank?
        return
      end

      # for a new attachment record, there has to be a file
      if @file.blank? and new_record?
        raise NoFile.new
      end

      # if it's not new, and it doesn't have a file?  it's okay, since the user
      # might be editing an attachment metadata, like description, etc.
      if @file.blank?
        return
      end

      # uploaded sound files are stored in data/ relative to app root
      base_path = get_base_path
      FileUtils.mkdir_p(base_path)

      # save self first, in order to get an id
      save validate: false

      # data/1.wav
      self.wav_name = id.to_s + '.wav'
      filepath = File.join(base_path, self.wav_name)

      # start copying file, allowing overrides
      File.open(filepath, "wb") do |new_file|
        new_file.write(@file.read)
      end
    end

    def delete_file
      FileUtils.rm(get_base_path.join(wav_name)) if !wav_name.blank? && File.exist?(get_base_path.join(wav_name))
      FileUtils.rm(get_base_path.join(ogg_name)) if !ogg_name.blank? && File.exist?(get_base_path.join(ogg_name))
    end

    def wav_or_ogg_defined?
      if wav_name.blank? && ogg_name.blank?
        errors.add(:base, "does not contain wav nor ogg filename")
        Rails.logger.error("Validation failed: both wav_name and ogg_name are blank.")
      end
    end

end
