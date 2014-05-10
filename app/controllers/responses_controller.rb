class ResponsesController < ApplicationController
  before_action :set_response, only: [:show, :edit, :update, :destroy]
  before_action :require_login

  # GET /responses
  def index
    @responses = Response.all
  end

  # GET /responses/1
  def show
  end

  # GET /responses/new
  def new
    @response = Response.new
    set_response_assignment
    return if !require_student @response.assignment.course
  end

  # POST /responses
  def create
    @response = Response.new(params.require(:response).permit(:audio_file_io))
    set_response_assignment
    return if !require_student @response.assignment.course
    set_response_user

    respond_to do |format|
      if @response.save
        format.html { redirect_to [@response.assignment.course, @response.assignment, @response], notice: 'Response was successfully created.' }
        format.js { flash[:notice] = 'Annotation was successfully created.'; render 'create' }
      else
        format.html { render action: 'new' }
        format.js { render 'create_fail' }
      end
    end
  end

  # PATCH/PUT /responses/1
  def update
    return if !require_teacher @response.assignment.course

    if current_user.teacher_of? @response.assignment.course
      clean_params = params.require(:response).permit(:score, :notes)
    else
      clean_params = params.require(:response).permit()
    end

    respond_to do |format|
      if @response.update(clean_params)
        format.html { redirect_to [@response.assignment.course, @response.assignment, @response], notice: 'Response was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /responses/1
  def destroy
    return if !require_student @response.assignment.course

    @response.destroy
    respond_to do |format|
      format.html { redirect_to [@response.assignment.course, @response.assignment] }
    end
  end

  # GET /responses/1/score/edit
  def edit_score
    @response = Response.find(params[:response_id])
    return if !require_teacher @response.assignment.course

    respond_to do |format|
      format.js
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_response
      @response = Response.find(params[:id])
    end

    def set_response_assignment
      @response.assignment = Assignment.find(params[:assignment_id])
    end

    def set_response_user
      @response.user = current_user
    end

end
