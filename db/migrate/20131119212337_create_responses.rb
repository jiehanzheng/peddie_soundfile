class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.integer :assignment_id
      t.integer :user_id
      t.integer :audio_file_id
      t.text :notes

      t.timestamps
    end
  end
end
