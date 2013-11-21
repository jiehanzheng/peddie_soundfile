class RenameSoundFileIdToAudioFileIdInAnnotations < ActiveRecord::Migration
  def change
    rename_column :annotations, :sound_file_id, :audio_file_id
  end
end
