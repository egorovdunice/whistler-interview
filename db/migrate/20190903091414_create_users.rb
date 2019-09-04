class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password
      t.string :username
      t.date :birthday
      t.string :status, default: 'standard'
      t.integer :month_points, default: 0
      t.integer :year_points, default: 0
      t.integer :last_year_points, default: 0
      t.timestamps
    end
  end
end
