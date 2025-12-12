class CreateBudgets < ActiveRecord::Migration[8.1]
  def change
    create_table :budgets do |t|
      t.string :category, null: false
      t.decimal :maximum_spend, precision: 10, scale: 2, null: false, default: 0
      t.string :theme, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
