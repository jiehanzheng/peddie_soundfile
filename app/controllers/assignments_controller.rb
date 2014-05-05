class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]
  before_action :require_login

  # Only teachers of this course can make edits.
  # 
  # Permission checking for new/create actions is written inline, as 
  # @assignment.course has not been set by the time before_action is ran.
  before_action only: [:edit, :update, :destroy] do
    require_teacher @assignment.course
  end


  # GET /assignments
  def index
    @assignments = Assignment.all
  end

  # GET /assignments/1
  def show
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
    set_assignment_course
    require_teacher @assignment.course
  end

  # GET /assignments/1/edit
  def edit
  end

  # POST /assignments
  def create
    @assignment = Assignment.new(assignment_params)
    set_assignment_course
    require_teacher @assignment.course

    respond_to do |format|
      if @assignment.save
        format.html { redirect_to [@assignment.course, @assignment], notice: 'Assignment was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /assignments/1
  def update
    respond_to do |format|
      if @assignment.update(assignment_params)
        format.html { redirect_to [@assignment.course, @assignment], notice: 'Assignment was successfully updated.' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /assignments/1
  def destroy
    @assignment.destroy
    respond_to do |format|
      format.html { redirect_to course_assignments_url }
    end
  end

  private
    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    def set_assignment_course
      @assignment.course = Course.find(params[:course_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assignment_params
      params.require(:assignment).permit(:name, :due_date)
    end
end
