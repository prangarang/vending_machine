class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :quantity, :available, :price_pence

  def available
    object.available?
  end
end
