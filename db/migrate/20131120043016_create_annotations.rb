class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.integer :response_id
      t.integer :sound_file_id
      t.float :start_second
      t.float :end_second
      t.text :notes

      t.timestamps
    end
  end
end
