# frozen_string_literal: true

require 'test_after_commit' if ActiveRecord::VERSION::MAJOR < 5
require File.expand_path('../../test_helper', __FILE__)

class IssuesTest < Redmine::IntegrationTest
  include ActiveJob::TestHelper
  include Redmine::I18n

  fixtures :email_addresses,
           :enabled_modules,
           :enumerations,
           :issues,
           :issue_statuses,
           :member_roles,
           :members,
           :projects,
           :projects_trackers,
           :roles,
           :user_preferences,
           :users,
           :trackers,
           :versions,
           :watchers,
           :workflows,
           :project_mail_preferences,
           :user_mail_preferences

  def setup
    Setting.bcc_recipients = false if Setting.available_settings.key?('bcc_recipients')
    Setting.notified_events = ['issue_added', 'issue_updated']
    ActionMailer::Base.deliveries.clear
  end

  def test_issue_add_disabled
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['issue_added']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      new_record(Issue) do
        post(
          '/projects/ecookbook/issues',
          params: {
            issue: {
              tracker_id: '1',
              start_date: '2000-01-01',
              priority_id: "5",
              subject: "test issue",
            }
          })
      end
    end

    assert_equal 1, ActionMailer::Base.deliveries.length

    mail0 = ActionMailer::Base.deliveries[0]

    assert_equal ['dlopper@somenet.foo'], mail0.to
  end

  def test_issue_add_enabled
    log_user('admin', 'admin')

    perform_enqueued_jobs do
      new_record(Issue) do
        post(
          '/projects/ecookbook/issues',
          params: {
            issue: {
              tracker_id: '1',
              start_date: '2000-01-01',
              priority_id: "5",
              subject: "test issue",
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to

      assert_include 'jsmith@somenet.foo', (to0 + to1)
      assert_include 'dlopper@somenet.foo', (to0 + to1)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 2, mail.to.length

      assert_include 'jsmith@somenet.foo', mail.to
      assert_include 'dlopper@somenet.foo', mail.to
    end
  end

  def test_issue_add_project_disabled
    p = projects(:projects_001)
    p.enable_module!(:mail_preferences)

    m = ProjectMailPreference.new
    m.project = p
    m.disable_notified_events = ['issue_added']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      new_record(Issue) do
        post(
          '/projects/ecookbook/issues',
          params: {
            issue: {
              tracker_id: '1',
              start_date: '2000-01-01',
              priority_id: "5",
              subject: "test issue",
            }
          })
      end
    end

    assert_equal 0, ActionMailer::Base.deliveries.length
  end

  def test_issue_edit_disabled_issue_updated
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['issue_updated']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              subject: "test issue",
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to

      assert_include 'admin@somenet.foo', (to0 + to1)
      assert_include 'dlopper@somenet.foo', (to0 + to1)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 1, mail.to.length
      assert_equal 1, mail.cc.length

      assert_include 'dlopper@somenet.foo', mail.to
      assert_include 'admin@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_disabled_issue_note_added
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['issue_updated', 'issue_note_added']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              notes: "note",
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to

      assert_include 'admin@somenet.foo', (to0 + to1)
      assert_include 'dlopper@somenet.foo', (to0 + to1)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 1, mail.to.length
      assert_equal 1, mail.cc.length

      assert_include 'dlopper@somenet.foo', mail.to
      assert_include 'admin@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_disabled_issue_status_updated
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['issue_updated', 'issue_status_updated']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              status_id: '3',
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to

      assert_include 'admin@somenet.foo', (to0 + to1)
      assert_include 'dlopper@somenet.foo', (to0 + to1)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 1, mail.to.length
      assert_equal 1, mail.cc.length

      assert_include 'dlopper@somenet.foo', mail.to
      assert_include 'admin@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_disabled_issue_assigned_to_updated
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['issue_updated', 'issue_assigned_to_updated']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              assigned_to_id: '2',
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to

      assert_include 'admin@somenet.foo', (to0 + to1)
      assert_include 'dlopper@somenet.foo', (to0 + to1)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 1, mail.to.length
      assert_equal 1, mail.cc.length

      assert_include 'dlopper@somenet.foo', mail.to
      assert_include 'admin@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_disabled_issue_priority_updated
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['issue_updated', 'issue_priority_updated']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              priority_id: '8',
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to

      assert_include 'admin@somenet.foo', (to0 + to1)
      assert_include 'dlopper@somenet.foo', (to0 + to1)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 1, mail.to.length
      assert_equal 1, mail.cc.length

      assert_include 'dlopper@somenet.foo', mail.to
      assert_include 'admin@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_disabled_issue_fixed_version_updated
    m = UserMailPreference.new
    m.user = users(:users_002)
    if Redmine::VERSION::MAJOR >= 4
      m.disable_notified_events = ['issue_updated', 'issue_fixed_version_updated']
    else
      m.disable_notified_events = ['issue_updated']
    end
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              fixed_version_id: '3',
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to

      assert_include 'admin@somenet.foo', (to0 + to1)
      assert_include 'dlopper@somenet.foo', (to0 + to1)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 1, mail.to.length
      assert_equal 1, mail.cc.length

      assert_include 'dlopper@somenet.foo', mail.to
      assert_include 'admin@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_enabled_issue_updated
    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              subject: "test issue",
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 3, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length
      assert_equal 1, ActionMailer::Base.deliveries[2].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to
      to2 = ActionMailer::Base.deliveries[2].to

      assert_include 'admin@somenet.foo', (to0 + to1 +  to2)
      assert_include 'jsmith@somenet.foo', (to0 + to1 +  to2)
      assert_include 'dlopper@somenet.foo', (to0 + to1 + to2)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 2, mail.to.length
      assert_equal 1, mail.cc.length

      assert_include 'jsmith@somenet.foo', mail.to
      assert_include 'dlopper@somenet.foo', mail.to
      assert_include 'admin@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_enabled_issue_note_added
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['issue_updated']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              notes: "note",
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 3, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length
      assert_equal 1, ActionMailer::Base.deliveries[2].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to
      to2 = ActionMailer::Base.deliveries[2].to

      assert_include 'admin@somenet.foo', (to0 + to1 +  to2)
      assert_include 'jsmith@somenet.foo', (to0 + to1 +  to2)
      assert_include 'dlopper@somenet.foo', (to0 + to1 + to2)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 2, mail.to.length
      assert_equal 1, mail.cc.length

      assert_include 'jsmith@somenet.foo', mail.to
      assert_include 'dlopper@somenet.foo', mail.to
      assert_include 'admin@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_enabled_issue_status_updated
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['issue_updated']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              status_id: '3',
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 3, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length
      assert_equal 1, ActionMailer::Base.deliveries[2].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to
      to2 = ActionMailer::Base.deliveries[2].to

      assert_include 'admin@somenet.foo', (to0 + to1 +  to2)
      assert_include 'jsmith@somenet.foo', (to0 + to1 +  to2)
      assert_include 'dlopper@somenet.foo', (to0 + to1 + to2)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 2, mail.to.length
      assert_equal 1, mail.cc.length

      assert_include 'jsmith@somenet.foo', mail.to
      assert_include 'dlopper@somenet.foo', mail.to
      assert_include 'admin@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_enabled_issue_assigned_to_updated
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['issue_updated']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              assigned_to_id: '2',
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 3, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length
      assert_equal 1, ActionMailer::Base.deliveries[2].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to
      to2 = ActionMailer::Base.deliveries[2].to

      assert_include 'admin@somenet.foo', (to0 + to1 +  to2)
      assert_include 'jsmith@somenet.foo', (to0 + to1 +  to2)
      assert_include 'dlopper@somenet.foo', (to0 + to1 + to2)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 2, mail.to.length
      assert_equal 1, mail.cc.length

      assert_include 'jsmith@somenet.foo', mail.to
      assert_include 'dlopper@somenet.foo', mail.to
      assert_include 'admin@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_enabled_issue_priority_updated
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['issue_updated']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              priority_id: '8',
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 3, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length
      assert_equal 1, ActionMailer::Base.deliveries[2].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to
      to2 = ActionMailer::Base.deliveries[2].to

      assert_include 'admin@somenet.foo', (to0 + to1 +  to2)
      assert_include 'jsmith@somenet.foo', (to0 + to1 +  to2)
      assert_include 'dlopper@somenet.foo', (to0 + to1 + to2)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 2, mail.to.length
      assert_equal 1, mail.cc.length

      assert_include 'jsmith@somenet.foo', mail.to
      assert_include 'dlopper@somenet.foo', mail.to
      assert_include 'admin@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_enabled_issue_fixed_version_updated
    m = UserMailPreference.new
    m.user = users(:users_002)
    if Redmine::VERSION::MAJOR >= 4
      m.disable_notified_events = ['issue_updated']
    else
      m.disable_notified_events = []
    end
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              fixed_version_id: '3',
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 3, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length
      assert_equal 1, ActionMailer::Base.deliveries[2].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to
      to2 = ActionMailer::Base.deliveries[2].to

      assert_include 'admin@somenet.foo', (to0 + to1 +  to2)
      assert_include 'jsmith@somenet.foo', (to0 + to1 +  to2)
      assert_include 'dlopper@somenet.foo', (to0 + to1 + to2)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 2, mail.to.length
      assert_equal 1, mail.cc.length

      assert_include 'jsmith@somenet.foo', mail.to
      assert_include 'dlopper@somenet.foo', mail.to
      assert_include 'admin@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_project_disabled_issue_updated
    p = projects(:projects_001)
    p.enable_module!(:mail_preferences)

    m = ProjectMailPreference.new
    m.project = p
    m.disable_notified_events = ['issue_updated']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              subject: "test issue",
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to

      assert_include 'admin@somenet.foo', (to0 + to1)
      assert_include 'dlopper@somenet.foo', (to0 + to1)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 0, mail.to.length
      assert_equal 2, mail.cc.length

      assert_include 'admin@somenet.foo', mail.cc
      assert_include 'dlopper@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_project_disabled_issue_note_added
    p = projects(:projects_001)
    p.enable_module!(:mail_preferences)

    m = ProjectMailPreference.new
    m.project = p
    m.disable_notified_events = ['issue_updated', 'issue_note_added']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              notes: "note",
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to

      assert_include 'admin@somenet.foo', (to0 + to1)
      assert_include 'dlopper@somenet.foo', (to0 + to1)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 0, mail.to.length
      assert_equal 2, mail.cc.length

      assert_include 'admin@somenet.foo', mail.cc
      assert_include 'dlopper@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_project_disabled_issue_status_updated
    p = projects(:projects_001)
    p.enable_module!(:mail_preferences)

    m = ProjectMailPreference.new
    m.project = p
    m.disable_notified_events = ['issue_updated', 'issue_status_updated']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              status_id: '3',
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to

      assert_include 'admin@somenet.foo', (to0 + to1)
      assert_include 'dlopper@somenet.foo', (to0 + to1)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 0, mail.to.length
      assert_equal 2, mail.cc.length

      assert_include 'admin@somenet.foo', mail.cc
      assert_include 'dlopper@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_project_disabled_issue_assigned_to_updated
    p = projects(:projects_001)
    p.enable_module!(:mail_preferences)

    m = ProjectMailPreference.new
    m.project = p
    m.disable_notified_events = ['issue_updated', 'issue_assigned_to_updated']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              assigned_to_id: '2',
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to

      assert_include 'admin@somenet.foo', (to0 + to1)
      assert_include 'dlopper@somenet.foo', (to0 + to1)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 0, mail.to.length
      assert_equal 2, mail.cc.length

      assert_include 'admin@somenet.foo', mail.cc
      assert_include 'dlopper@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_project_disabled_issue_priority_updated
    p = projects(:projects_001)
    p.enable_module!(:mail_preferences)

    m = ProjectMailPreference.new
    m.project = p
    m.disable_notified_events = ['issue_updated', 'issue_priority_updated']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              priority_id: '8',
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to

      assert_include 'admin@somenet.foo', (to0 + to1)
      assert_include 'dlopper@somenet.foo', (to0 + to1)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 0, mail.to.length
      assert_equal 2, mail.cc.length

      assert_include 'admin@somenet.foo', mail.cc
      assert_include 'dlopper@somenet.foo', mail.cc
    end
  end

  def test_issue_edit_project_disabled_issue_fixed_version_updated
    p = projects(:projects_001)
    p.enable_module!(:mail_preferences)

    m = ProjectMailPreference.new
    m.project = p
    if Redmine::VERSION::MAJOR >= 4
      m.disable_notified_events = ['issue_updated', 'issue_fixed_version_updated']
    else
      m.disable_notified_events = ['issue_updated']
    end
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      put_issue_edit do
        put(
          '/issues/2',
          params: {
            issue: {
              fixed_version_id: '3',
            }
          })
      end
    end

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to

      assert_include 'admin@somenet.foo', (to0 + to1)
      assert_include 'dlopper@somenet.foo', (to0 + to1)
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 0, mail.to.length
      assert_equal 2, mail.cc.length

      assert_include 'admin@somenet.foo', mail.cc
      assert_include 'dlopper@somenet.foo', mail.cc
    end
  end

  def put_issue_edit(&block)
    if ActiveRecord::VERSION::MAJOR >= 5
      yield
    else
      TestAfterCommit.with_commits(true, &block)
    end
  end
end
