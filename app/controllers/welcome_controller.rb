class WelcomeController < ApplicationController
  def index
    unless current_user
      render 'index_public'
    end

    @todo_assignments = Assignment.joins(
      'INNER JOIN courses ON courses.id = assignments.course_id
       INNER JOIN enrollments ON enrollments.course_id = courses.id
       INNER JOIN users ON users.id = enrollments.user_id
       LEFT OUTER JOIN responses ON users.id = responses.user_id AND assignments.id = responses.assignment_id'
    ).where(responses: {id: nil}, users: {id: current_user.id})
    
    @recently_graded_assignments = current_user.responses.order(updated_at: :desc).where.not(score: nil).limit(5)
  end
end
