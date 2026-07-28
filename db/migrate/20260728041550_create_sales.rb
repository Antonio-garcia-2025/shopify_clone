class CreateSales < ActiveRecord::Migration[8.1]
  def change
    create_table :sales do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :price

      t.timestamps
    end
  end
end
