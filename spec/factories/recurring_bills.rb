FactoryBot.define do
  factory :recurring_bill do
    association :user
    bill_title { Faker::Lorem.word }
    amount     { rand(10..1000) }

    frequency_type { "Weekly" }
    day_of_week    { "Monday" }
    day_of_month   { nil }

    # ADD THIS ↓↓↓
    next_due_date { Date.today + 3.days }

    trait :monthly do
      frequency_type { "Monthly" }
      day_of_month { 10 }
      day_of_week { nil }
    end

    trait :yearly do
      frequency_type { "Yearly" }
      day_of_month { 10 }
      day_of_week { nil }
    end
  end
end
