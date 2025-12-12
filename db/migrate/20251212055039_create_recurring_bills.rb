class CreateRecurringBills < ActiveRecord::Migration[8.1]
  def change
    create_table :recurring_bills do |t|
      t.string :bill_title, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :frequency_type, null: false # e.g., "Monthly", "Weekly", "Yearly"
      t.integer :day_of_month # For monthly bills (1-31)
      t.string :day_of_week # For weekly bills (e.g., "Monday")
      t.date :next_due_date # Calculated next occurrence
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :recurring_bills, :next_due_date
  end
end
