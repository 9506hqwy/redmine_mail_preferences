# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class NewssTest < Redmine::IntegrationTest
  include ActiveJob::TestHelper
  include Redmine::I18n

  fixtures :comments,
           :email_addresses,
           :enabled_modules,
           :enumerations,
           :member_roles,
           :members,
           :news,
           :projects,
           :roles,
           :user_preferences,
           :users,
           :watchers,
           :project_mail_preferences,
           :user_mail_preferences

  def setup
    Setting.bcc_recipients = false if Setting.available_settings.key?('bcc_recipients')
    Setting.notified_events = ['news_added', 'news_comment_added']
    ActionMailer::Base.deliveries.clear
  end

  def test_news_add_disabled
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['news_added']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      new_record(News) do
        post(
          '/projects/ecookbook/news',
          params: {
            news: {
              title: 'test',
              description: 'test',
              summary: "test",
            }
          })
      end
    end

    assert_equal 1, ActionMailer::Base.deliveries.length

    mail0 = ActionMailer::Base.deliveries[0]

    assert_equal ['dlopper@somenet.foo'], mail0.to
  end

  def test_news_add_enabled
    log_user('admin', 'admin')

    perform_enqueued_jobs do
      new_record(News) do
        post(
          '/projects/ecookbook/news',
          params: {
            news: {
              title: 'test',
              description: 'test',
              summary: "test",
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

  def test_news_comment_add_disabled
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['news_comment_added']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      post(
        '/news/1/comments',
        params: {
          comment: {
            comments: "test",
          },
        })
    end

    assert_equal 1, ActionMailer::Base.deliveries.length

    mail0 = ActionMailer::Base.deliveries[0]

    assert_equal ['dlopper@somenet.foo'], mail0.to
  end

  def test_news_comment_add_enabled
    log_user('admin', 'admin')

    perform_enqueued_jobs do
      post(
        '/news/1/comments',
        params: {
          comment: {
            comments: "test",
          },
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

  def test_news_add_project_disabled
    p = projects(:projects_001)
    p.enable_module!(:mail_preferences)

    m = ProjectMailPreference.new
    m.project = p
    m.disable_notified_events = ['news_added']
    m.save!

    log_user('admin', 'admin')

    perform_enqueued_jobs do
      new_record(News) do
        post(
          '/projects/ecookbook/news',
          params: {
            news: {
              title: 'test',
              description: 'test',
              summary: "test",
            }
          })
      end
    end

    assert_equal 0, ActionMailer::Base.deliveries.length
  end
end
