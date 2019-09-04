class Transaction < ApplicationRecord
  belongs_to :user

  after_create :update_points

  def update_points
    u = self.user
    is_foreign = self.country != u.country
    points = (self.amount / 100) * 10 * (is_foreign ? 2 : 1)
    u.update(month_points: (u.month_points.to_i + points), year_points: (u.year_points.to_i + points))
  end
end
