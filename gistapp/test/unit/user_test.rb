require 'test_helper'

class UserTest < ActiveSupport::TestCase

  should have_many(:user_friendships)
  should have_many(:friends)

  test "a user should enter a first name" do
  	user = User.new
  	assert !user.save
  	assert !user.errors[:first_name].empty?
  end

 test "a user should enter a last name" do
  	user = User.new
  	assert !user.save
  	assert !user.errors[:last_name].empty?
  end

  test "a user should enter a profile name" do
  	user = User.new
  	assert !user.save
  	assert !user.errors[:profile_name].empty?
  end

  test "a user should have a unique profile name" do
  	user = User.new
  	user.profile_name = users(:seun).profile_name
  	users(:seun)
  	assert !user.save
  	assert !user.errors[:profile_name].empty?
  end

  test " a user should have a profile name without spaces" do
  	user = User.new(first_name: 'Seun', last_name: 'Adekoje', email: 'seun3000@gmail.com')
    user.password = user.password_confirmation = 'password'
  	user.profile_name = 'Contains spaces'
  	assert !user.save
  	assert !user.errors[:profile_name].empty?
  	assert user.errors[:profile_name].include?("Must be formatted correctly.")
  end

    test "a user can have a correctly formatted profile name" do
    user = User.new(first_name: 'Kerry', last_name: 'Washington', email: 'kerry@example.com')
    user.password = user.password_confirmation = 'password'

    user.profile_name = 'kerry'
    assert user.valid?
  end

  test "that no error is raised when trying to access a friend list" do
    assert_nothing_raised do 
      users(:seun).friends
    end
  end
  test "that creating friendships on a user works" do 
    users(:seun).pending_friends << users(:patrick)
    users(:seun).pending_friends.reload
    assert users(:seun).pending_friends.include?(users(:patrick))
  end
  test "that calling to_param on a user returns the profile_name" do
    assert_equal "seunade", users(:seun).to_param
  end
end
