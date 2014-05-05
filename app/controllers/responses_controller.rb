class ResponsesController < ApplicationController
  before_action :set_response, only: [:show, :edit, :update, :destroy]
  before_action :require_login

  # Only students of this course can make edits.
  # 
  # Permission checking for new/create actions is written inline, as 
  # @response.assignment has not been set by the time before_action is ran.
  before_action only: [:edit, :update, :destroy] do
    require_student @response.assignment.course
  end

  # GET /responses
  # GET /responses.json
  def index
    @responses = Response.all
  end

  # GET /responses/1
  # GET /responses/1.json
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
  # POST /responses.json
  def create
    @response = Response.new(response_params)
    set_response_assignment
    require_student @response.assignment.course
    set_response_user

    respond_to do |format|
      if @response.save
        format.html { redirect_to [@response.assignment.course, @response.assignment, @response], notice: 'Response was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /responses/1
  # PATCH/PUT /responses/1.json
  def update
    respond_to do |format|
      if @response.update(response_params)
        format.html { redirect_to [@response.assignment.course, @response.assignment, @response], notice: 'Response was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /responses/1
  # DELETE /responses/1.json
  def destroy
    @response.destroy
    respond_to do |format|
      format.html { redirect_to responses_url }
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def response_params
      params.require(:response).permit(:audio_file_io, :notes)
    end
end
