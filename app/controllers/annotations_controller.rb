class AnnotationsController < ApplicationController
  before_action :set_annotation, only: [:show, :edit, :update, :destroy]
  before_action :require_login

  # GET /annotations
  # GET /annotations.json
  def index
    response = Response.find(params[:response_id])
    return if !require_same_user_or_teacher(response.user, response.assignment.course)
    @annotations = response.annotations
  end

  # GET /annotations/new
  def new
    @annotation = Annotation.new
    set_annotation_response
    return if !require_teacher @annotation.response.assignment.course
  end

  # GET /annotations/1/edit
  def edit
    return if !require_teacher @annotation.response.assignment.course
  end

  # POST /annotations
  def create
    @annotation = Annotation.new(annotation_params)
    set_annotation_response
    return if !require_teacher @annotation.response.assignment.course

    respond_to do |format|
      if @annotation.save
        format.html { redirect_to [@annotation.response.assignment.course, @annotation.response.assignment, @annotation.response], notice: 'Annotation was successfully created.' }
        format.js { flash[:notice] = 'Annotation was successfully created.'; render 'create' }
      else
        format.html { render action: 'new' }
        format.js { render 'create_fail' }
      end
    end
  end

  # PATCH/PUT /annotations/1
  def update
    return if !require_teacher @response.assignment.course

    respond_to do |format|
      if @annotation.update(annotation_params)
        format.html { redirect_to [@annotation.response.assignment.course, @annotation.response.assignment, @annotation.response], notice: 'Annotation was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /annotations/1
  def destroy
    return if !require_teacher @response.assignment.course

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
