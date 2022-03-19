# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class WikiContentTest < ActiveSupport::TestCase
  fixtures :enabled_modules,
           :member_roles,
           :members,
           :projects,
           :roles,
           :users,
           :wiki_contents,
           :wiki_pages,
           :wikis,
           :project_mail_preferences,
           :user_mail_preferences

  def setup
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['wiki_content_added', 'wiki_content_updated']
    m.save!
  end

  def test_notified_users_disable
    wiki_content = wiki_contents(:wiki_contents_001)
    u = deliver_wiki_content_added(wiki_content)
    assert_equal 1, u.length
    assert_include users(:users_003), u
  end

  def test_notified_users_disable_updated
    wiki_content = wiki_contents(:wiki_contents_001)
    u = deliver_wiki_content_updated(wiki_content)
    assert_equal 1, u.length
    assert_include users(:users_003), u
  end

  def test_notified_users_enable
    wiki_content = wiki_contents(:wiki_contents_001)
    u = deliver_wiki_content_unknown(wiki_content)
    assert_equal 2, u.length
    assert_include users(:users_002), u
    assert_include users(:users_003), u
  end

  private

  def deliver_wiki_content_added(wiki_content)
    wiki_content.notified_users
  end

  def deliver_wiki_content_updated(wiki_content)
    wiki_content.notified_users
  end

  def deliver_wiki_content_unknown(wiki_content)
    wiki_content.notified_users
  end
end
