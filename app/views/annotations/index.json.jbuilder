json.array!(@annotations) do |annotation|
  json.extract! annotation, :id, :start_second, :end_second, :notes
  json.sound_file polymorphic_url(annotation.audio_file, format: :audio_file, :routing_type => :path)
end
