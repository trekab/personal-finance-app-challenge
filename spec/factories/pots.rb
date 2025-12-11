FactoryBot.define do
  factory :pot do
    pot_name { Faker::Lorem.word }
    target { "9000" }
    theme { Pot::THEMES.sample }
    user
  end
end
