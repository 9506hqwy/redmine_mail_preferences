# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class UserMailPreferenceTest < ActiveSupport::TestCase
  fixtures :users,
           :user_mail_preferences

  def test_create
    u = users(:users_002)

    p = UserMailPreference.new
    p.user = u
    p.disable_notified_events = ['issue_added', 'issue_updated']
    p.save!

    p.reload
    assert_equal u.id, p.user_id
    assert_equal 2, p.disable_notified_events.length
    assert_includes p.disable_notified_events, 'issue_added'
    assert_includes p.disable_notified_events, 'issue_updated'
  end

  def test_update
    u = users(:users_001)

    p = u.mail_preferences
    p.disable_notified_events = ['issue_added', 'issue_updated']
    p.save!

    p.reload
    assert_equal u.id, p.user_id
    assert_equal 2, p.disable_notified_events.length
    assert_includes p.disable_notified_events, 'issue_added'
    assert_includes p.disable_notified_events, 'issue_updated'
  end
end
