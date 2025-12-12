class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.datetime :date, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :category, null: false
      t.integer :transaction_type, null: false
      t.references :customizable, polymorphic: true, null: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
