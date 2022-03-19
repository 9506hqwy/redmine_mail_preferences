# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class JournalTest < ActiveSupport::TestCase
  fixtures :enabled_modules,
           :issues,
           :journals,
           :journal_details,
           :member_roles,
           :members,
           :projects,
           :roles,
           :users,
           :project_mail_preferences,
           :user_mail_preferences

  def test_notified_users_description_disable
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events =
      [
        'issue_note_added',
        'issue_updated',
      ]
    m.save!

    journal = journals(:journals_003)
    u = deliver_issue_edit(journal)
    assert_equal 1, u.length
    assert_include users(:users_003), u
  end

  def test_notified_users_description_enable
    journal = journals(:journals_003)
    u = deliver_issue_unknown(journal)
    assert_equal 2, u.length
    assert_include users(:users_002), u
    assert_include users(:users_003), u
  end

  def test_notified_users_fixed_version_id_disable
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events =
      [
        'issue_fixed_version_updated',
        'issue_note_added',
        'issue_updated',
      ]
    m.save!

    journal = journals(:journals_004)
    u = deliver_issue_edit(journal)
    assert_equal 1, u.length
    assert_include users(:users_001), u
  end

  def test_notified_users_fixed_version_id_enable
    journal = journals(:journals_004)
    u = deliver_issue_unknown(journal)
    assert_equal 2, u.length
    assert_include users(:users_001), u
    assert_include users(:users_002), u
  end

  def test_notified_users_status_disable
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events =
      [
        'issue_note_added',
        'issue_status_updated',
        'issue_updated',
      ]
    m.save!

    journal = journals(:journals_001)
    u = deliver_issue_edit(journal)
    assert_equal 1, u.length
    assert_include users(:users_003), u
  end

  def test_notified_users_status_enable
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
