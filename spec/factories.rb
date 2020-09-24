FactoryBot.define do
  factory :product do
    name { Faker::Lorem.word }
    quantity { 100 }
    price_pence { Faker::Number.number(digits: 3) }
  end

  factory :denomination do
    value { 1 }
    quantity { 100 }

    trait :pound do
      value { 100 }
    end
  end

  factory :checkout do
    product
    total_amount { 100 }
    total_amount_paid { 0 }
    status { 'requires_payment' }
  end
end
