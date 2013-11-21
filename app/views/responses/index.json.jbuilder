json.array!(@responses) do |response|
  json.extract! response, :assignment_id, :user_id, :audio_file_id, :notes
  json.url response_url(response, format: :json)
end
