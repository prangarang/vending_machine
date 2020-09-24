# frozen_string_literal: true

class Denomination < ApplicationRecord
  include QuantityManageable

  SUPPORTED_DENOMINATIONS = [1, 2, 5, 10, 20, 50, 100, 200].freeze

  scope :available, -> { where('quantity > 0') }

  validates :value, presence: true, inclusion: { in: SUPPORTED_DENOMINATIONS }
  validates_uniqueness_of :value
  validates_numericality_of :value, greater_than_or_equal_to: 0
end
