class Change
  # @!attribute [rw] coins_used
  #   @return [Hash<Denomination, Integer>] Hash of denominations to be used for change and the quantity of those denominations to use
  attr_accessor :coins_used, :coin_count, :total_amount

  # @param [Integer] coin_count The number of coins needed to make this change. This should sum up to the total
  # @param [Hash<Denomination, Integer>] coins_used Hash of denominations to be used for change and the quantity of those denominations to use
  # @param [Integer] total_change The total change to return in base currency
  def initialize(coin_count, coins_used, total_amount)
    @coin_count = coin_count
    @coins_used = coins_used
    @total_amount = total_amount
  end
end
