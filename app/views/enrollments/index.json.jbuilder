json.array!(@enrollments) do |enrollment|
  json.extract! enrollment, :id, :course_id, :user_id, :user_role
  json.url enrollment_url(enrollment, format: :json)
end
