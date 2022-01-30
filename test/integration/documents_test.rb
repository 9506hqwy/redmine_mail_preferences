# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class DocumentsTest < Redmine::IntegrationTest
  include Redmine::I18n

  fixtures :documents,
           :email_addresses,
           :enabled_modules,
           :enumerations,
           :member_roles,
           :members,
           :projects,
           :roles,
           :users,
           :user_mail_preferences

  def setup
    Setting.bcc_recipients = false
    Setting.notified_events = ['document_added']
    ActionMailer::Base.deliveries.clear
  end

  def test_document_add_disabled
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['document_added']
    m.save!

    log_user('admin', 'admin')

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

    assert_equal 1, ActionMailer::Base.deliveries.length

    mail0 = ActionMailer::Base.deliveries[0]

    assert_equal ['dlopper@somenet.foo'], mail0.to
  end

  def test_document_add_enabled
    log_user('admin', 'admin')

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

    if Redmine::VERSION::MAJOR >= 4
      assert_equal 2, ActionMailer::Base.deliveries.length

      mail0 = ActionMailer::Base.deliveries[0]
      mail1 = ActionMailer::Base.deliveries[1]

      assert_equal ['jsmith@somenet.foo'], mail0.to
      assert_equal ['dlopper@somenet.foo'], mail1.to
    else
      assert_equal 1, ActionMailer::Base.deliveries.length

      mail = ActionMailer::Base.deliveries[0]
      assert_equal 2, mail.to.length

      assert_include 'jsmith@somenet.foo', mail.to
      assert_include 'dlopper@somenet.foo', mail.to
    end
  end
end
