json.array!(@annotations) do |annotation|
  json.extract! annotation, :start_second, :end_second, :notes
  json.sound_file polymorphic_url(annotation.audio_file, format: :audio_file, :routing_type => :path)
  json.url polymorphic_url([@response, annotation], format: :json, :routing_type => :path)
end
