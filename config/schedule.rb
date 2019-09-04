every 1.month, at: '0:02 am' do
  runner "User.add_birthday_reward"
end

every 1.month, at: '0:03 am' do
  runner "User.reset_month_points"
end

every 1.year, at: '0:04 am' do
  runner "User.reset_year_points"
end

every 3.month, at: '0:05 am' do
  runner "User.add_quarterly_points"
end

