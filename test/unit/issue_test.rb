# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class IssueTest < ActiveSupport::TestCase
  fixtures :enabled_modules,
           :issues,
           :member_roles,
           :members,
           :projects,
           :roles,
           :users,
           :project_mail_preferences,
           :user_mail_preferences

  def setup
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['issue_added']
    m.save!
  end

  def test_notified_users_disable
    issue = issues(:issues_001)
    u = deliver_issue_add(issue)
    assert_equal 1, u.length
    assert_include users(:users_003), u
  end

  def test_notified_users_enable
    issue = issues(:issues_001)
    u = deliver_issue_unknown(issue)
    assert_equal 2, u.length
    assert_include users(:users_002), u
    assert_include users(:users_003), u
  end

  private

  def deliver_issue_add(issue)
    issue.notified_users
  end

  def deliver_issue_unknown(issue)
    issue.notified_users
  end
end
