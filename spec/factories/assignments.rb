FactoryGirl.define do
  sequence :assignment_name do |n|
    "Lesson #{n}"
  end

  factory :assignment do
    name { generate(:assignment_name) }

    after(:create) do |assignment, evaluator|
      create_list(:response, 1, assignment: assignment)
    end
  end
end
