class AudioFilesController < ApplicationController
  before_action :set_audio_file, only: [:show, :edit, :update, :destroy]

  # GET /audio_files
  # GET /audio_files.json
  def index
    @audio_files = AudioFile.all
  end

  # GET /audio_files/1
  # GET /audio_files/1.download
  def show
    respond_to do |format|
      format.html
      format.audio_file { send_file @audio_file.path, :type => @audio_file.mime_type }
    end
  end

  # GET /audio_files/new
  def new
    @audio_file = AudioFile.new
  end

  # GET /audio_files/1/edit
  def edit
  end

  # POST /audio_files
  def create
    @audio_file = AudioFile.new(audio_file_params)

    respond_to do |format|
      if @audio_file.save
        format.html { redirect_to @audio_file, notice: 'Audio file was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /audio_files/1
  def update
    respond_to do |format|
      if @audio_file.update(audio_file_params)
        format.html { redirect_to @audio_file, notice: 'Audio file was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /audio_files/1
  def destroy
    @audio_file.destroy
    respond_to do |format|
      format.html { redirect_to audio_files_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_audio_file
      @audio_file = AudioFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def audio_file_params
      params.require(:audio_file).permit(:wav_file)
    end
end
