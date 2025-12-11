class CreatePots < ActiveRecord::Migration[8.1]
  def change
    create_table :pots do |t|
      t.string :pot_name, null: false
      t.decimal :target, precision: 10, scale: 2, null: false, default: 0
      t.string :theme, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
