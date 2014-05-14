FactoryGirl.define do
  sequence :course_name do |n|
    "AP Chinese #{n}"
  end

  factory :course do
    name { generate(:course_name) }

    factory :course_with_assignments do
      after(:create) do |course, evaluator|
        create_list(:assignment, 1, course: course)
      end
    end
  end
end
