class ResponsesController < ApplicationController
  before_action :set_response, only: [:show, :edit, :update, :destroy]
  before_action :require_login
  before_action only: [:edit, :update] do
    require_teacher @response.assignment.course
  end

  # Only students of this course can make edits.
  # 
  # Permission checking for new/create actions is written inline, as 
  # @response.assignment has not been set by the time before_action is ran.
  before_action only: [:destroy] do
    require_student @response.assignment.course
  end

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
    require_student @response.assignment.course
  end

  # GET /responses/1/edit
  def edit
  end

  # POST /responses
  def create
    @response = Response.new(params.require(:response).permit(:audio_file_io))
    set_response_assignment
    require_student @response.assignment.course
    set_response_user

    respond_to do |format|
      if @response.save
        format.html { redirect_to [@response.assignment.course, @response.assignment, @response], notice: 'Response was successfully created.' }
        format.js { render 'create' }
      else
        format.html { render action: 'new' }
        format.js { render 'create_fail' }
      end
    end
  end

  # PATCH/PUT /responses/1
  def update
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
    @response.destroy
    respond_to do |format|
      format.html { redirect_to [@response.assignment.course, @response.assignment] }
    end
  end

  # GET /responses/1/score/edit
  def edit_score
    @response = Response.find(params[:response_id])
    require_teacher @response.assignment.course

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
