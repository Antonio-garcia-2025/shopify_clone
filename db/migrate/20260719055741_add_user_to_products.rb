class AddUserToProducts < ActiveRecord::Migration[8.1]
  def change
    add_reference :products, :user, null: true, foreign_key: true
  end
end
