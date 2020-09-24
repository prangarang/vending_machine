class CheckoutSerializer < ActiveModel::Serializer
  attributes :id, :total_amount, :total_amount_payable, :status, :total_amount_paid, :change

  def total_amount_balance
    object.total_amount_payable
  end

  def change
    change_object = instance_options[:change]
    if change_object
      {
          total_amount: change_object.total_amount,
          coin_count: change_object.coin_count,
          denominations: change_object.coins_used.map { |denom, cnt| {denom.value => cnt} }
      }
    else
      {}
    end
  end
end
