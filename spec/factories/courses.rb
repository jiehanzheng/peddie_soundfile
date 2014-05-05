FactoryGirl.define do
  sequence :course_name do |n|
    "AP Chinese #{n}"
  end

  factory :course do
    name { generate(:course_name) }
  end
end
