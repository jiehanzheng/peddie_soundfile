json.array!(@audio_files) do |audio_file|
  json.extract! audio_file, :wav_name, :ogg_name, :path, :convert_tries
  json.url audio_file_url(audio_file, format: :json)
end
