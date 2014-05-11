class AudioFilesController < ApplicationController
  before_action :set_audio_file, only: [:show, :edit, :update, :destroy]
  before_action :require_login

  # GET /audio_files/1.ogg
  def show
    return if !require_same_user_or_teacher(@audio_file.associated_student, @audio_file.associated_course)
    
    respond_to do |format|
      format.ogg { send_file @audio_file.path }
    end
  end

  private
    def set_audio_file
      @audio_file = AudioFile.find(params[:id])
    end
end
