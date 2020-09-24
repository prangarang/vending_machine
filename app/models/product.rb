class Product < ApplicationRecord
  include QuantityManageable

  has_many :checkouts
end
