FactoryGirl.define do
  sequence :email do |n|
    "jdoe#{n}@peddie.org"
  end

  factory :user, aliases: [:student, :teacher] do
    provider 'google_oauth2'
    first_name 'John'
    last_name 'Doe'
    email
  end
end
