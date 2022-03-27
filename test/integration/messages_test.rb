# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class MessagesTest < Redmine::IntegrationTest
  include ActiveJob::TestHelper
  include Redmine::I18n

  fixtures :boards,
           :email_addresses,
           :enabled_modules,
           :enumerations,
           :member_roles,
           :members,
           :messages,
           :projects,
           :roles,
           :user_preferences,
           :users,
           :watchers,
           :project_mail_preferences,
           :user_mail_preferences

  def setup
    Setting.bcc_recipients = false if Setting.available_settings.key?('bcc_recipients')
    Setting.notified_events = ['message_posted']
    ActionMailer::Base.deliveries.clear
  end

  def test_message_posted_disabled
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['message_posted']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      new_record(Message) do
        post(
          '/boards/1/topics/new',
          params: {
            message: {
              subject: 'test',
              content: 'test',
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

  def test_message_posted_enabled
    log_user('admin', 'admin')

    perform_enqueued_jobs do
      new_record(Message) do
        post(
          '/boards/1/topics/new',
          params: {
            message: {
              subject: 'test',
              content: 'test',
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

      assert_include 'admin@somenet.foo', (to0 + to1 + to2)
      assert_include 'jsmith@somenet.foo', (to0 + to1 + to2)
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

  def test_message_posted_project_disabled
    p = projects(:projects_001)
    p.enable_module!(:mail_preferences)

    m = ProjectMailPreference.new
    m.project = p
    m.disable_notified_events = ['message_posted']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      new_record(Message) do
        post(
          '/boards/1/topics/new',
          params: {
            message: {
              subject: 'test',
              content: 'test',
            }
          })
      end
    end

    assert_equal 1, ActionMailer::Base.deliveries.length
    if Redmine::VERSION::MAJOR >= 4
      assert_equal 1, ActionMailer::Base.deliveries.last.to.length
      assert_include 'admin@somenet.foo', ActionMailer::Base.deliveries.last.to
    else
      mail = ActionMailer::Base.deliveries[0]
      assert_equal 0, mail.to.length
      assert_equal 1, mail.cc.length

      assert_include 'admin@somenet.foo', mail.cc
    end
  end
end
