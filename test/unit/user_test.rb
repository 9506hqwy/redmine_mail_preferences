# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class UserTest < ActiveSupport::TestCase
  fixtures :users,
           :user_mail_preferences

  def test_destroy
    u = users(:users_001)
    u.destroy!

    begin
      user_mail_preferences(:user_mail_preferences_001)
      assert false
    rescue ActiveRecord::RecordNotFound
      assert true
    end
  end
end
