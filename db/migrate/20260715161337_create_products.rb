class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price, precision: 8, scale: 2
      t.integer :stock, default: 0

      t.timestamps
    end
  end
end

#update the migration to precision 8, because the maximum value for price is 999999.99, which requires a precision of 8 and a scale of 2.