# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class MessageTest < ActiveSupport::TestCase
  fixtures :boards,
           :enabled_modules,
           :member_roles,
           :messages,
           :members,
           :projects,
           :roles,
           :users,
           :project_mail_preferences,
           :user_mail_preferences

  def setup
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['message_posted']
    m.save!
  end

  def test_notified_users_disable
    message = messages(:messages_001)
    u = deliver_message_posted(message)
    assert_equal 1, u.length
    assert_include users(:users_003), u
  end

  def test_notified_users_enable
    message = messages(:messages_001)
    u = deliver_message_unknown(message)
    assert_equal 2, u.length
    assert_include users(:users_002), u
    assert_include users(:users_003), u
  end

  private

  def deliver_message_posted(message)
    message.notified_users
  end

  def deliver_message_unknown(message)
    message.notified_users
  end
end
