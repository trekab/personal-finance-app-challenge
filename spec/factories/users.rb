FactoryBot.define do
  factory :user do
    email_address { "users@example.com" }
    name { "Example User" }
    password { "password" }
  end
end
