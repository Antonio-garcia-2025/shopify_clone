class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :products, dependent: :destroy
  has_many :sales, dependent: :destroy
  has_many :categories, dependent: :destroy
end