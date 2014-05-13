class WelcomeController < ApplicationController
  def index
    if current_user
      if current_user.admin?
        # is admin...show a list of everything
        @courses = Course.all.reverse_order
        @users = User.all.reverse_order
        @assignments = Assignment.all.reverse_order
        @responses = Response.all.reverse_order

        render 'index_admin'
        return
      else
        # show todo and responses to a user (or teacher)
        # if someone has too much free time please implement a teacher interface too
        @todo_assignments = Assignment.joins(
          'INNER JOIN courses ON courses.id = assignments.course_id
           INNER JOIN enrollments ON enrollments.course_id = courses.id
           INNER JOIN users ON users.id = enrollments.user_id
           LEFT OUTER JOIN responses ON users.id = responses.user_id AND assignments.id = responses.assignment_id'
        ).where(responses: {id: nil}, users: {id: current_user.id}, enrollments: {user_role: Enrollment.user_roles[:student]})
        
        @recently_graded_responses = current_user.responses.order(updated_at: :desc).where.not(score: nil).limit(5)
      end
    else
      render 'index_public'
    end
  end
end
