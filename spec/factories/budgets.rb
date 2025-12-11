FactoryBot.define do
  factory :budget do
    category { Budget::CATEGORIES.sample }
    maximum_spend { "9000" }
    theme { Budget::THEMES.sample }
    user
  end
end
