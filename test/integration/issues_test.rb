# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class IssuesTest < Redmine::IntegrationTest
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
           :users,
           :trackers,
           :user_mail_preferences

  def setup
    Setting.bcc_recipients = false
    Setting.notified_events = ['issue_added', 'issue_updated']
    ActionMailer::Base.deliveries.clear
  end

  def test_issue_add_disabled
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['issue_added']
    m.save!

    log_user('admin', 'admin')

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

    assert_equal 1, ActionMailer::Base.deliveries.length

    mail0 = ActionMailer::Base.deliveries[0]

    assert_equal ['dlopper@somenet.foo'], mail0.to
  end

  def test_issue_add_enabled
    log_user('admin', 'admin')

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

  def test_issue_edit_disabled
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['issue_updated']
    m.save!

    log_user('admin', 'admin')

    put(
      '/issues/2',
      params: {
        issue: {
          subject: "test issue",
        }
      })

    # FIXME: 0 at test only in Redmine3
    assert_equal 1, ActionMailer::Base.deliveries.length

    mail0 = ActionMailer::Base.deliveries[0]

    assert_equal ['dlopper@somenet.foo'], mail0.to
  end

  def test_issue_edit_enabled
    log_user('admin', 'admin')

    put(
      '/issues/2',
      params: {
        issue: {
          subject: "test issue",
        }
      })

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length
      assert_equal 1, ActionMailer::Base.deliveries[0].to.length
      assert_equal 1, ActionMailer::Base.deliveries[1].to.length

      to0 = ActionMailer::Base.deliveries[0].to
      to1 = ActionMailer::Base.deliveries[1].to

      assert_include 'jsmith@somenet.foo', (to0 + to1)
      assert_include 'dlopper@somenet.foo', (to0 + to1)
    else
      # FIXME: 0 at test only in Redmine3
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 2, mail.to.length

      assert_include 'jsmith@somenet.foo', mail.to
      assert_include 'dlopper@somenet.foo', mail.to
    end
  end
end
