class AnnotationsController < ApplicationController
  before_action :set_annotation, only: [:show, :edit, :update, :destroy]

  # GET /annotations
  # GET /annotations.json
  def index
    @annotations = Response.find(params[:response_id]).annotations
  end

  # GET /annotations/1
  # GET /annotations/1.json
  def show
  end

  # GET /annotations/new
  def new
    @annotation = Annotation.new
    set_annotation_response
  end

  # GET /annotations/1/edit
  def edit
  end

  # POST /annotations
  # POST /annotations.json
  def create
    @annotation = Annotation.new(annotation_params)
    set_annotation_response

    # TODO: permission check

    respond_to do |format|
      if @annotation.save
        format.html { redirect_to [@annotation.response.assignment.course, @annotation.response.assignment, @annotation.response], notice: 'Annotation was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /annotations/1
  # PATCH/PUT /annotations/1.json
  def update
    respond_to do |format|
      if @annotation.update(annotation_params)
        format.html { redirect_to [@annotation.response.assignment.course, @annotation.response.assignment, @annotation.response], notice: 'Annotation was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /annotations/1
  # DELETE /annotations/1.json
  def destroy
    @annotation.destroy
    respond_to do |format|
      format.html { redirect_to annotations_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_annotation
      @annotation = Annotation.find(params[:id])
    end

    def set_annotation_response
      @annotation.response = Response.find(params[:response_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def annotation_params
      params.require(:annotation).permit(:audio_file_io, :start_second, :end_second, :notes)
    end
end
