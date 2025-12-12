FactoryBot.define do
  factory :transaction do
    date { Time.current }
    amount { "5000" }
    category { Constants::Categories::LIST.sample }
    user
  end
end
