require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(email: "james@gmail.com" , password: "123")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.email = ""
    assert_not @user.valid?
  end
end
