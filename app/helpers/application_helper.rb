module ApplicationHelper
  def name_list(users)
    users.map do |user|
      user.full_name
    end.join(', ')
  end

  def set_title(title)
    @title = title
  end

  def page_title
    if @title.blank?
      "Peddie Sound File"
    else
      @title + ' - ' + "Peddie Sound File"
    end
  end

end
