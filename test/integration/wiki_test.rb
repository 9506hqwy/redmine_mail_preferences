# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class WikiTest < Redmine::IntegrationTest
  include Redmine::I18n

  fixtures :email_addresses,
           :enabled_modules,
           :enumerations,
           :member_roles,
           :members,
           :projects,
           :roles,
           :users,
           :wiki_content_versions,
           :wiki_contents,
           :wiki_pages,
           :wikis,
           :user_mail_preferences

  def setup
    Setting.bcc_recipients = false
    Setting.notified_events = ['wiki_content_added', 'wiki_content_updated']
    ActionMailer::Base.deliveries.clear
  end

  def test_wiki_content_added_disabled
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['wiki_content_added']
    m.save!

    log_user('admin', 'admin')

    new_record(WikiContent) do
      put(
        '/projects/ecookbook/wiki/Wiki',
        params: {
          content: {
            text: "wiki content"
          }
        })
    end

    assert_equal 1, ActionMailer::Base.deliveries.length

    mail0 = ActionMailer::Base.deliveries[0]

    assert_equal ['dlopper@somenet.foo'], mail0.to
  end

  def test_wiki_content_added_enabled
    log_user('admin', 'admin')

    new_record(WikiContent) do
      put(
        '/projects/ecookbook/wiki/Wiki',
        params: {
          content: {
            text: "wiki content"
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

  def test_wiki_content_updated_disabled
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['wiki_content_updated']
    m.save!

    log_user('admin', 'admin')

    put(
      '/projects/ecookbook/wiki/CookBook_documentation',
      params: {
        content: {
          text: "wiki content"
        }
      })

    assert_equal 1, ActionMailer::Base.deliveries.length

    mail0 = ActionMailer::Base.deliveries[0]

    assert_equal ['dlopper@somenet.foo'], mail0.to
  end

  def test_wiki_content_updated_enabled
    log_user('admin', 'admin')

    put(
      '/projects/ecookbook/wiki/CookBook_documentation',
      params: {
        content: {
          text: "wiki content"
        }
      })

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
