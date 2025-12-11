FactoryBot.define do
  factory :user do
    email_address { "#{SecureRandom.uuid}@example.com" }
    name { "Example User" }
    password { "password" }
  end
end
