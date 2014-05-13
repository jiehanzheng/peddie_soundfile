module AudioFileAttachable
  extend ActiveSupport::Concern

  included do
    belongs_to :audio_file, :dependent => :destroy
    before_create :save_attachment
  end

  def audio_file_io=(uploaded_io)
    @audio_file_io = uploaded_io
  end

  private
    def save_attachment
      unless audio_file.blank?
        Rails.logger.debug "audio_file is blank, skipping save_attachment..."
        return
      end

      Rails.logger.debug "Creating and populating AudioFile object..."
      this_audio_file = AudioFile.new
      this_audio_file.file = @audio_file_io
      this_audio_file.save!

      self.audio_file = this_audio_file
    end
end
