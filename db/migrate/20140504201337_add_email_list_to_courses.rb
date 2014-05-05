class AddEmailListToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :email_list, :text
  end
end
