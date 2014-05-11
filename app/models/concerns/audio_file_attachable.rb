module AudioFileAttachable
  extend ActiveSupport::Concern

  included do
    belongs_to :audio_file, :dependent => :destroy
    before_create :save_attachment

    validates_associated :audio_file
  end

  def audio_file_io=(uploaded_io)
    @audio_file_io = uploaded_io
  end

  private
    def save_attachment
      if defined? audio_file
        return
      end

      this_audio_file = AudioFile.new
      this_audio_file.file = @audio_file_io
      this_audio_file.save!

      self.audio_file = this_audio_file
    end
end
