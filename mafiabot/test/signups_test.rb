require "test/unit"
require "../signups.rb"

class SignupsTest < Test::Unit::TestCase
	def test_new
		signups = Signup.new
		assert_equal([], signups.users)
		assert_equal(true, signups.newgame?)
	end
end