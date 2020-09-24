class Product < ApplicationRecord
  include QuantityManageable

  scope :available, -> { where('quantity > 0') }

  has_many :checkouts
end
