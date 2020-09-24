# Class used for processing change including the calculation of the change and the decremting of it from out system.
class ChangeProcessor
  class ProcessingError < StandardError; end

  def self.process_using_available_denoms!(total_amount)
    self.new(total_amount: total_amount, denominations: Denomination.all).process!
  end

  # @param [Integer] total_amount
  # @param [Array<Denomination>] denominations
  # @param [Class<ChangeCalculator>] calculator class that operates as a change calculator
  def initialize(total_amount:, denominations:, calculator: ChangeCalculator)
    @total_amount = total_amount
    @calculator = calculator
    @denominations = denominations
  end

  # @return [Change] the amount of change that was processed
  # @raise [ChangeProcessingError] raised if change cannot be met with the current inventory of denominations in our system
  def process!
    raise ProcessingError if @denominations.empty?
    raise ProcessingError, 'total_amount is negative. Did you mean to pass a positive number?' if @total_amount.negative?
    return Change.new(0, {}, 0) if @total_amount == 0

    change = @calculator.new(@denominations, @total_amount).calculate
    change.coins_used.each { |denomination, cnt| denomination.decrement_quantity!(cnt) }
    change
  rescue => e
    raise ProcessingError
  end
end