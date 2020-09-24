class Checkout < ApplicationRecord
  belongs_to :product

  enum status: { 'requires_payment': 0, 'succeeded': 1, 'failed': 2 }

  before_save :update_status

  validates_presence_of :status, :total_amount, :total_amount_paid
  validates :total_amount, numericality: { greater_than: 0 }

  # @return [0] if no more money to be collected because they have paid exact amount or more than needed
  # @return [Integer] if positive amount of money to be collected
  def total_amount_payable
    diff = total_amount_balance
    diff < 0 ? 0 : diff
  end

  # @return [Integer] balance (positive/negative) of total pence owed minus collected. Negative if paid more than total price.
  def total_amount_balance
    total_amount - total_amount_paid
  end

  def increment_total_amount_paid!(new_amount_pence)
    self.update!(total_amount_paid: total_amount_paid + new_amount_pence)
  end

  private


  def update_status
    if total_amount_payable == 0
      self.status = 'succeeded'
    end
  end
end
