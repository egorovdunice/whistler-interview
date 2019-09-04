class User < ApplicationRecord
  has_many :rewards, dependent: :destroy
  has_many :transactions, dependent: :destroy

  before_update :check_status

  def check_status
    if transactions.length > 0
      points = [year_points.to_i, last_year_points.to_i].max
      status =
      case points
      when 0..1000
        'standard'
      when 1000..5000
        'gold'
      else
        'platinum'
      end
      if status != self.status
        self.status = status
        4.times {rewards.create(reward_type: :airport)} if status == 'gold'
      end
      check_movie if rewards.where(reward_type: :movie).count == 0 and (Time.current - transactions.first.created_at) / 1.day <= 60
      check_rebate if rewards.where(reward_type: :rebate).count == 0
      check_month_coffee if rewards.where(reward_type: :coffee, birthday: false, expires_at: Time.current.end_of_month).count == 0
    end
  end

  def check_movie
    rewards.create(reward_type: :movie) if transactions.sum('amount') > 1000
  end

  def check_rebate
    rewards.create(reward_type: :rebate) if transactions.where('amount > 100').count > 9
  end

  def check_month_coffee
    rewards.create(reward_type: :coffee, expires_at: Time.current.end_of_month) if month_points >= 100
  end

  def add_quarterly_points
    last_quarter = Time.current.last_quarter
    start_date = last_quarter.beginning_of_quarter
    end_date = last_quarter.end_of_quarter
    if transactions.where(created_at: start_date..end_date).sum('amount') > 2000
      update(year_points: year_points.to_i + 100)
    end
  end

  def self.add_birthday_coffee
    User.all.each do |user|
      if user.birthday&.month == Date.current.month &&
          user.rewards.where(reward_type: :coffee, birthday: true, expires_at: Time.current.end_of_month).count == 0
        user.rewards.create(reward_type: :coffee, expires_at: Time.current.end_of_month, birthday: true)
      end
    end
  end

  def self.reset_month_points
    User.update_all(month_points: 0)
  end

  def self.reset_year_points
    User.update_all("last_year_points = year_points, year_points = 0")
  end
end
