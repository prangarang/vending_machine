class CreateDenominations < ActiveRecord::Migration[6.0]
  def change
    create_table :denominations do |t|
      t.integer :value
      t.integer :quantity
      t.timestamps
    end
  end
end
