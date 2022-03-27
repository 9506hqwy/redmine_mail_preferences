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
           :user_preferences,
           :users,
           :watchers,
           :wiki_content_versions,
           :wiki_contents,
           :wiki_pages,
           :wikis,
           :project_mail_preferences,
           :user_mail_preferences

  def setup
    Setting.bcc_recipients = false if Setting.available_settings.key?('bcc_recipients')
    Setting.notified_events = ['wiki_content_added', 'wiki_content_updated', 'wiki_comment_added']
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

  def test_wiki_content_added_project_disabled
    p = projects(:projects_001)
    p.enable_module!(:mail_preferences)

    m = ProjectMailPreference.new
    m.project = p
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

    assert_equal 0, ActionMailer::Base.deliveries.length
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

  def test_wiki_content_updated_project_disabled
    p = projects(:projects_001)
    p.enable_module!(:mail_preferences)

    m = ProjectMailPreference.new
    m.project = p
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

    assert_equal 0, ActionMailer::Base.deliveries.length
  end

  def test_wiki_comment_added_disabled
    skip unless Redmine::Plugin.installed?(:redmine_wiki_extensions)
    skip unless Redmine::VERSION::MAJOR >= 4

    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['wiki_comment_added']
    m.save!

    projects(:projects_001).enable_module!(:wiki_extensions)
    roles(:roles_001).add_permission!(:add_wiki_comment)

    page = wiki_pages(:wiki_pages_001)
    page.add_watcher(users(:users_001))

    log_user('jsmith', 'jsmith')

    post(
      '/projects/ecookbook/wiki_extensions/add_comment',
      params: {
        wiki_page_id: page.id,
        comment: 'test comment',
      })

    assert_equal 2, ActionMailer::Base.deliveries.length
    assert_equal 1, ActionMailer::Base.deliveries[0].to.length
    assert_equal 1, ActionMailer::Base.deliveries[1].to.length

    t0 = ActionMailer::Base.deliveries[0].to
    t1 = ActionMailer::Base.deliveries[1].to

    assert_include 'admin@somenet.foo', (t0 + t1)
    assert_include 'dlopper@somenet.foo', (t0 + t1)
  end

  def test_wiki_comment_added_enabled
    skip unless Redmine::Plugin.installed?(:redmine_wiki_extensions)
    skip unless Redmine::VERSION::MAJOR >= 4

    projects(:projects_001).enable_module!(:wiki_extensions)
    roles(:roles_001).add_permission!(:add_wiki_comment)

    page = wiki_pages(:wiki_pages_001)
    page.add_watcher(users(:users_001))

    log_user('jsmith', 'jsmith')

    post(
      '/projects/ecookbook/wiki_extensions/add_comment',
      params: {
        wiki_page_id: page.id,
        comment: 'test comment',
      })

    assert_equal 3, ActionMailer::Base.deliveries.length
    assert_equal 1, ActionMailer::Base.deliveries[0].to.length
    assert_equal 1, ActionMailer::Base.deliveries[1].to.length
    assert_equal 1, ActionMailer::Base.deliveries[2].to.length

    t0 = ActionMailer::Base.deliveries[0].to
    t1 = ActionMailer::Base.deliveries[1].to
    t2 = ActionMailer::Base.deliveries[2].to

    assert_include 'admin@somenet.foo', (t0 + t1 + t2)
    assert_include 'jsmith@somenet.foo', (t0 + t1 + t2)
    assert_include 'dlopper@somenet.foo', (t0 + t1 + t2)
  end

  def test_wiki_comment_added_project_disabled
    skip unless Redmine::Plugin.installed?(:redmine_wiki_extensions)
    skip unless Redmine::VERSION::MAJOR >= 4

    p = projects(:projects_001)
    p.enable_module!(:mail_preferences)

    m = ProjectMailPreference.new
    m.project = p
    m.disable_notified_events = ['wiki_comment_added']
    m.save!

    projects(:projects_001).enable_module!(:wiki_extensions)
    roles(:roles_001).add_permission!(:add_wiki_comment)

    page = wiki_pages(:wiki_pages_001)
    page.add_watcher(users(:users_001))

    log_user('jsmith', 'jsmith')

    post(
      '/projects/ecookbook/wiki_extensions/add_comment',
      params: {
        wiki_page_id: page.id,
        comment: 'test comment',
      })

    assert_equal 1, ActionMailer::Base.deliveries.length
    assert_equal 1, ActionMailer::Base.deliveries.last.to.length
    assert_include 'admin@somenet.foo', ActionMailer::Base.deliveries.last.to
  end
end
