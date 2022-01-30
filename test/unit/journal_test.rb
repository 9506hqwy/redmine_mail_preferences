# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class JournalTest < ActiveSupport::TestCase
  fixtures :journals,
           :member_roles,
           :members,
           :projects,
           :roles,
           :users,
           :user_mail_preferences

  def setup
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['issue_updated']
    m.save!
  end

  def test_notified_users_disable
    journal = journals(:journals_001)
    u = deliver_issue_edit(journal)
    assert_equal 1, u.length
    assert_include users(:users_003), u
  end

  def test_notified_users_enable
    journal = journals(:journals_001)
    u = deliver_issue_unknown(journal)
    assert_equal 2, u.length
    assert_include users(:users_002), u
    assert_include users(:users_003), u
  end

  private

  def deliver_issue_edit(journal)
    journal.notified_users
  end

  def deliver_issue_unknown(journal)
    journal.notified_users
  end
end
