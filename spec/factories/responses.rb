FactoryGirl.define do
  factory :response do
    audio_file
    user
    after(:create) do |response, evaluator|
      create_list(:annotation, 1, response: response)
    end
  end
end
