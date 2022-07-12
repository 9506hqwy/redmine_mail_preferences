# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class UtilsTest < ActiveSupport::TestCase
  fixtures :issues,
           :projects,
           :users,
           :project_mail_preferences,
           :user_mail_preferences

  def test_disable_event_for_001
    u = users(:users_001)
    assert RedmineMailPreferences::Utils.disable_event_for(u, ['issue_added'])
    assert RedmineMailPreferences::Utils.disable_event_for(u, ['issue_updated'])
    assert_not RedmineMailPreferences::Utils.disable_event_for(u, ['new_added'])
  end

  def test_disable_event_for_002
    u = users(:users_002)
    assert_not RedmineMailPreferences::Utils.disable_event_for(u, ['issue_added'])
  end

  def test_remove_by_disabled_event_t
    issue = issues(:issues_001)
    users = [users(:users_001), users(:users_002)]
    users = deliver_issue_add(issue, users)
    assert_equal 1, users.length
    assert_include users(:users_002), users
  end

  def test_remove_by_disabled_event_f
    issue = issues(:issues_001)
    users = [users(:users_001), users(:users_002)]
    users = issue_add(issue, users)
    assert_equal 2, users.length
    assert_include users(:users_001), users
    assert_include users(:users_002), users
  end

  private

  def call_remove_by_disabled_event(container, users)
    RedmineMailPreferences::Utils.remove_by_disabled_event(container, users)
  end

  def deliver_issue_add(container, users)
    call_remove_by_disabled_event(container, users)
  end

  def issue_add(container, users)
    call_remove_by_disabled_event(container, users)
  end
end
