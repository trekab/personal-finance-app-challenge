json.extract! transaction, :id, :date, :amount, :category, :user_id, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
