# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class MessagesTest < Redmine::IntegrationTest
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
           :users,
           :user_mail_preferences

  def setup
    Setting.bcc_recipients = false
    Setting.notified_events = ['message_posted']
    ActionMailer::Base.deliveries.clear
  end

  def test_message_posted_disabled
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['message_posted']
    m.save!

    log_user('admin', 'admin')

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

    assert_equal 1, ActionMailer::Base.deliveries.length

    mail0 = ActionMailer::Base.deliveries[0]

    assert_equal ['dlopper@somenet.foo'], mail0.to
  end

  def test_message_posted_enabled
    log_user('admin', 'admin')

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
end
