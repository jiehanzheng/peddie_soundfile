module ApplicationHelper
  def name_list(users)
    users.map do |user|
      user.full_name
    end.join(', ')
  end
end
