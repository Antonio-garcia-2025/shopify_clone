class Product < ApplicationRecord


    belongs_to :user

    validates :name, presence: true
    validates :price, numericality: { greater_than_or_equal_to: 0 }
    validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    
end