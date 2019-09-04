class CreateRewards < ActiveRecord::Migration[6.0]
  def change
    create_table :rewards do |t|
      t.string :reward_type
      t.datetime :expires_at
      t.boolean :birthday, default: false
      t.timestamps
    end
    add_reference :rewards, :user, index: true
  end
end
