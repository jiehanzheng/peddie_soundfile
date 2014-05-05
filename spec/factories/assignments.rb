FactoryGirl.define do
  sequence :assignment_name do |n|
    "Lesson #{n}"
  end

  factory :assignment do
    name { generate(:assignment_name) }
  end
end
