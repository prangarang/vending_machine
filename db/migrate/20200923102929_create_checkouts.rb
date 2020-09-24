class CreateCheckouts < ActiveRecord::Migration[6.0]
  def change
    create_table :checkouts do |t|
      t.integer :total_amount, null: false
      t.integer :total_amount_paid, default:0, null: false
      t.integer :status, default: 0, null: false
      t.references :product, null: false, foreign_key: true
      t.timestamps
    end
  end
end
