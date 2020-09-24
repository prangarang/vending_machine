# frozen_string_literal: true

# Class for calculating the change needed to meet a specific total based on the availability of denominations in our system.
class ChangeCalculator
  class ChangeIncalculableError < StandardError; end

  # @param [Array<Denomination>] denominations
  # @param [Integer] total
  def initialize(denominations, total)
    @subtotals = Array.new(total + 1) { |i| Change.new(Float::INFINITY, {}, i) }
    @subtotals[0] = Change.new(0, {}, 0)

    # We need to ensure the denominations are in reverse order as we need to ensure that when we process the lower
    # denominations we have already precomputed how many coins were used at larger denominations. This is important
    # because we have a limited number of coins and thus need to max out usage of higher denomination coins first.
    # A use case this comes up is if we max out the higher denomination coins to get to correct change (ie 5 - 100 and 5
    # - 200 and need to generate 1500 change).
    @denominations = denominations.sort.reverse
    @total = total
  end

  # Calculates the change needed based on availability of denominations in the system. If the change, can't be met an
  # error will be raised. This method does not deduct the change from the system's inventory. This needs to be performed
  # by the caller or by using the {ChangeProcessor} class
  #
  # @return [Change] change required
  # @raise [ChangeIncalculableError] raised if change cannot be met with the current inventory of denominations in our system
  def calculate
    @denominations.each do |denomination|
      # Loop from the denomination_value of the denomination up through the total change trying to generate
      # At each incremental subtotal, figure out the minimum amount of coins we can use without exhausting availability
      # by looking at the minimum coins used at the subtotal - denomination point. If that is more efficient than the current
      # change set at the subtotal, then overwrite it with the new calculation.
      (denomination.value..@total).each do |subtotal|
        determine_minimum_coins_used(denomination, subtotal)
      end
    end

    raise ChangeIncalculableError if @subtotals[@total].coin_count == Float::INFINITY

    @subtotals[@total]
  end

  private

  # For a denomination at a specific subtotal, tries to figure out if using the coin at this subtotal is more efficient
  # than previous attempts at calculating change at this subtotal. If it is more efficient, then it stores the results
  # in the subtotals array at the subtotal index.
  #
  # @param [Denomination] denominations
  # @param [Integer] subtotal
  # @return [null]
  # @private
  def determine_minimum_coins_used(denomination, subtotal)
    difference = subtotal - denomination.value
    change_at_difference = @subtotals[difference]
    denomination_used_at_difference = change_at_difference.coins_used.fetch(denomination, 0)
    coin_count_if_used = change_at_difference.coin_count + 1

    change_at_subtotal = @subtotals[subtotal]
    # Use the denomination if the total coins used less than the existing coin counts used AND if we still have coins
    # available to use (based on the coins used at the subtotal difference)
    if coin_count_if_used < change_at_subtotal.coin_count && denomination_used_at_difference < denomination.quantity
      # Set coin count to the new coin count
      change_at_subtotal.coin_count = coin_count_if_used

      # Increment the count used of the denomination value since we are using it
      change_at_subtotal.coins_used = change_at_difference.coins_used.dup
      change_at_subtotal.coins_used[denomination] = 0 if change_at_subtotal.coins_used[denomination].nil?
      change_at_subtotal.coins_used[denomination] += 1
      @subtotals[subtotal] = change_at_subtotal
    end
  end
end
