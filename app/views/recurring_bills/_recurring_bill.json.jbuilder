json.extract! recurring_bill, :id, :bill_title, :amount, :frequency_type, :day_of_month, :day_of_week, :next_due_date, :is_overdue, :color, :user_id, :created_at, :updated_at
json.url recurring_bill_url(recurring_bill, format: :json)
