class AudioFilesController < ApplicationController
  before_action :set_audio_file, only: [:show, :edit, :update, :destroy]

  # GET /audio_files/1.ogg
  def show
    respond_to do |format|
      format.ogg { send_file @audio_file.path }
    end
  end

  private
    def set_audio_file
      @audio_file = AudioFile.find(params[:id])
    end
end
