class Reward < ApplicationRecord
  belongs_to :user
  enum reward_type: [:coffee, :rebate, :movie, :airport]
end
