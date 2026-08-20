class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :products, dependent: :destroy
  has_many :sales, dependent: :destroy
  has_many :categories, dependent: :destroy

  after_create :seed_default_categories

  private
  def seed_default_categories
    default_categories = ['Electronics', 'Books', 'Clothing', 'Home & Kitchen', 'Sports & Outdoors']
    default_categories.each do |category_name|
      self.categories.create(name: category_name)
    end
  end
end