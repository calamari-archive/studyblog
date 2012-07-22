ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require "authlogic/test_case"
require 'declarative_authorization/maintenance'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  setup :activate_authlogic
  # Add more helper methods to be used by all tests here...
  include Authorization::TestHelper

  def create_user
    user = User.new :username => 'Bill', :email => 'a@a.de', :password => 'pass1234', :password_confirmation => 'pass1234', :role => 'participant', :active => false
    user.username = 'Bill'
    user.email = 'a@a.de'
    user.password = 'pass1234'
    user.password_confirmation = 'pass1234'
    user.role = 'participant'
    user.active = false
    user
  end
end
