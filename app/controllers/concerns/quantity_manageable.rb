module QuantityManageable
  class UnableToDecrementQuantityError < StandardError; end;
  extend ActiveSupport::Concern

  def increment_quantity!(by = 1)
    increment!(:quantity, by)
  end

  def decrement_quantity!(by = 1)
    if quantity - by >= 0
      decrement!(:quantity, by)
    else
      raise UnableToDecrementQuantityError
    end
  end

  def available?
    quantity > 0
  end
end