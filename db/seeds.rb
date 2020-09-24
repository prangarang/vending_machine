# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Denomination::SUPPORTED_DENOMINATIONS.each do |denom_val|
  Denomination.create!(value: denom_val, quantity: 100)
end

Product.create(name: 'Sprite', price_pence: 50, quantity: 10)
Product.create(name: 'Coca Cola', price_pence: 34, quantity: 10)
Product.create(name: 'Pepsi', price_pence: 75, quantity: 10)
Product.create(name: 'Vodka', price_pence: 44, quantity: 10)
Product.create(name: 'Cat', price_pence: 250, quantity: 10)

