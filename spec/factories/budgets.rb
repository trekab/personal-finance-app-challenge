FactoryBot.define do
  factory :budget do
    category { Constants::Categories::LIST.sample }
    maximum_spend { "9000" }
    theme { Budget::THEMES.sample }
    user
  end
end
