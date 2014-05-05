class CreateEnrollments < ActiveRecord::Migration
  def change
    create_table :enrollments do |t|
      t.integer :course_id
      t.integer :user_id
      t.integer :user_role

      t.timestamps
    end
  end
end
