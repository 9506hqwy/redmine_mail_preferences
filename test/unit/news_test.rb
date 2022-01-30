# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class NewsTest < ActiveSupport::TestCase
  fixtures :member_roles,
           :members,
           :news,
           :projects,
           :roles,
           :users,
           :user_mail_preferences

  def setup
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['news_added', 'news_comment_added']
    m.save!
  end

  def test_notified_users_disable
    news = news(:news_001)
    u = deliver_news_added(news)
    assert_equal 1, u.length
    assert_include users(:users_003), u
  end

  def test_notified_users_disable_comment
    news = news(:news_001)
    u = deliver_news_comment_added(news)
    assert_equal 1, u.length
    assert_include users(:users_003), u
  end

  def test_notified_users_enable
    news = news(:news_001)
    u = deliver_news_unknown(news)
    assert_equal 2, u.length
    assert_include users(:users_002), u
    assert_include users(:users_003), u
  end

  private

  def deliver_news_added(news)
    news.notified_users
  end

  def deliver_news_comment_added(news)
    news.notified_users
  end

  def deliver_news_unknown(news)
    news.notified_users
  end
end
