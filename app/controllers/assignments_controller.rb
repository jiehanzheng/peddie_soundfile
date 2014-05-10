class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]
  before_action :require_login


  # GET /assignments/1
  def show
    return if !require_student @assignment.course
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
    set_assignment_course
    return if !require_teacher @assignment.course
  end

  # GET /assignments/1/edit
  def edit
    return if !require_teacher @assignment.course
  end

  # POST /assignments
  def create
    @assignment = Assignment.new(assignment_params)
    set_assignment_course
    return if !require_teacher @assignment.course

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
    return if !require_teacher @assignment.course

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
    return if !require_teacher @assignment.course

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
