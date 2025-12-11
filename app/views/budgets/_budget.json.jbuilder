json.extract! budget, :id, :budget_category, :maximum_spend, :theme, :user_id, :created_at, :updated_at
json.url budget_url(budget, format: :json)
