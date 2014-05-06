class RemoveWavFieldsFromAudioFiles < ActiveRecord::Migration
  def change
    remove_column :audio_files, :wav_name, :string
    remove_column :audio_files, :ogg_name, :string
    remove_column :audio_files, :path, :string
    remove_column :audio_files, :convert_tries, :integer
  end
end
