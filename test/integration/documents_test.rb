# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class DocumentsTest < Redmine::IntegrationTest
  include ActiveJob::TestHelper
  include Redmine::I18n

  fixtures :documents,
           :email_addresses,
           :enabled_modules,
           :enumerations,
           :member_roles,
           :members,
           :projects,
           :roles,
           :user_preferences,
           :users,
           :watchers,
           :project_mail_preferences,
           :user_mail_preferences

  def setup
    Setting.bcc_recipients = false if Setting.available_settings.key?('bcc_recipients')
    Setting.notified_events = ['document_added']
    ActionMailer::Base.deliveries.clear
  end

  def test_document_add_disabled
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['document_added']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      new_record(Document) do
        post(
          '/projects/ecookbook/documents',
          params: {
            document: {
              title: 'test',
              description: 'test',
              category_id: "1",
            }
          })
      end
    end

    assert_equal 1, ActionMailer::Base.deliveries.length

    mail0 = ActionMailer::Base.deliveries[0]

    assert_equal ['dlopper@somenet.foo'], mail0.to
  end

  def test_document_add_enabled
    log_user('admin', 'admin')

    perform_enqueued_jobs do
      new_record(Document) do
        post(
          '/projects/ecookbook/documents',
          params: {
            document: {
              title: 'test',
              description: 'test',
              category_id: "1",
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

  def test_document_add_project_disabled
    p = projects(:projects_001)
    p.enable_module!(:mail_preferences)

    m = ProjectMailPreference.new
    m.project = p
    m.disable_notified_events = ['document_added']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      new_record(Document) do
        post(
          '/projects/ecookbook/documents',
          params: {
            document: {
              title: 'test',
              description: 'test',
              category_id: "1",
            }
          })
      end
    end

    assert_equal 0, ActionMailer::Base.deliveries.length
  end
end
