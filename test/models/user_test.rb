require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.create({
      email: 'test@test.com',
      password: '123456',
      birthday: Date.today - 27.year,
      username: 'John',
      country: 'Russia'
    })
  end

  test 'Points: receiving by transaction' do
    assert_equal 0, @user.year_points
    @user.transactions.create(amount: 250, country: 'Russia')
    assert_equal 20, @user.year_points
    assert_equal 20, @user.month_points
    @user.transactions.create(amount: 100, country: 'Ukraine')
    assert_equal 40, @user.year_points
    assert_equal 40, @user.month_points
  end

  test 'Issuing rewards: month coffee' do
    assert_equal 0, @user.rewards.count
    @user.transactions.create(amount: 1000, country: 'Russia')
    assert_equal 1, @user.rewards.where(reward_type: :coffee).count
  end

  test 'Issuing rewards: birthday coffee' do
    assert_equal 0, @user.rewards.count
    @user.add_birthday_coffee
    assert_equal 1, @user.rewards.where(reward_type: :coffee, birthday: true).count
  end

  test 'Issuing rewards: cash rebate' do
    assert_equal 0, @user.rewards.count
    @user.transactions.create(amount: 200, country: 'Russia')
    assert_equal 0, @user.rewards.count
    9.times {@user.transactions.create(amount: 200, country: 'Russia')}
    assert_equal 1, @user.rewards.where(reward_type: :rebate).count
  end

  test 'Issuing rewards: movie ticket' do
    assert_equal 0, @user.rewards.count
    @user.transactions.create(amount: 2000, country: 'Russia')
    assert_equal 1, @user.rewards.where(reward_type: :movie).count
  end

  test 'Issuing rewards: movie ticket (late)' do
    assert_equal 0, @user.rewards.count
    @user.transactions.create(amount: 2000, country: 'Russia', created_at: '2017-12-12')
    assert_equal 0, @user.rewards.where(reward_type: :movie).count
  end

  test 'Loyalty tiers: change status' do
    @user.transactions.create(amount: 100, country: 'Russia')
    assert_equal 'standard', @user.status
    @user.transactions.create(amount: 10000, country: 'Russia')
    assert_equal 'gold', @user.status
    @user.transactions.create(amount: 50000, country: 'Russia')
    assert_equal 'platinum', @user.status
  end

  test 'Loyalty tiers: points expire every year' do
    @user.transactions.create(amount: 10000, country: 'Russia')
    assert_equal 0, @user.last_year_points
    assert_equal 1000, @user.year_points
    @user.reset_year_points
    assert_equal 1000, @user.last_year_points
    assert_equal 0, @user.year_points
  end

  test 'Loyalty tiers: highest points in the last 2 cycles' do
    @user.transactions.create(amount: 20000, country: 'Russia')
    assert_equal 0, @user.last_year_points
    assert_equal 2000, @user.year_points
    assert_equal 'gold', @user.status
    @user.reset_year_points
    @user.transactions.create(amount: 1000, country: 'Russia')
    assert_equal 2000, @user.last_year_points
    assert_equal 100, @user.year_points
    assert_equal 'gold', @user.status
    @user.transactions.create(amount: 59000, country: 'Russia')
    assert_equal 2000, @user.last_year_points
    assert_equal 6000, @user.year_points
    assert_equal 'platinum', @user.status
  end

  test 'Loyalty tiers: Airport Lounge Access Reward' do
    assert_equal 0, @user.rewards.count
    @user.transactions.create(amount: 20000, country: 'Russia')
    assert_equal 'gold', @user.status
    assert_equal 4, @user.rewards.where(reward_type: :airport).count
  end

  test 'Loyalty tiers: quarterly reward' do
    assert_equal 0, @user.year_points
    @user.transactions.create(amount: 20000, country: 'Russia', created_at: Time.current.last_quarter)
    assert_equal 2000, @user.year_points
    @user.add_quarterly_points
    assert_equal 2100, @user.year_points
  end

end
