class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.integer :amount
      t.string :country
      t.timestamps
    end
    add_reference :transactions, :user, index: true
  end
end
