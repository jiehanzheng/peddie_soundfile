class Response < ActiveRecord::Base

  belongs_to :audio_file, :dependent => :destroy
  has_many :annotations, :dependent => :destroy

  before_create :save_attachment

  def audio_file_io=(uploaded_io)
    @audio_file_io = uploaded_io
  end

  private
    def save_attachment
      this_audio_file = AudioFile.new
      this_audio_file.file = @audio_file_io
      this_audio_file.save!

      self.audio_file = this_audio_file
    end

end
