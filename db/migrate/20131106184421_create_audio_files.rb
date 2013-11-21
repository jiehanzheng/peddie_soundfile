class CreateAudioFiles < ActiveRecord::Migration
  def change
    create_table :audio_files do |t|
      t.string :wav_name
      t.string :ogg_name
      t.string :path
      t.integer :convert_tries

      t.timestamps
    end
  end
end
