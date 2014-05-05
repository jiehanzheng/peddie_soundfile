crumb :root do
  link "Dashboard", root_path
end

crumb :courses do
  link "My courses"
  parent :root
end

crumb :course do |course|
  link course.name, course
  parent :root
end

crumb :assignment do |assignment|
  link assignment.name, [assignment.course, assignment]
  parent :course, assignment.course
end

crumb :response do |response|
  link (''.html_safe + response.user.full_name + '&rsquo;'.html_safe + 's response').html_safe, [response.assignment.course, response.assignment, response]
  parent :assignment, response.assignment
end

# crumb :projects do
#   link "Projects", projects_path
# end

# crumb :project do |project|
#   link project.name, project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).