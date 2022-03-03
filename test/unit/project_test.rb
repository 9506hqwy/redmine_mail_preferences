# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class ProjectTest < ActiveSupport::TestCase
  fixtures :enabled_modules,
           :member_roles,
           :members,
           :projects,
           :roles,
           :users,
           :user_mail_preferences

  def setup
    m = UserMailPreference.new
    m.user = users(:users_002)
    m.disable_notified_events = ['file_added']
    m.save!
  end

  def test_notified_users_disable
    project = projects(:projects_001)
    u = deliver_attachments_added(project)
    assert_equal 1, u.length
    assert_include users(:users_003), u
  end

  def test_notified_users_enable
    project = projects(:projects_001)
    u = deliver_attachments_unknown(project)
    assert_equal 2, u.length
    assert_include users(:users_002), u
    assert_include users(:users_003), u
  end

  private

  def deliver_attachments_added(project)
    project.notified_users
  end

  def deliver_attachments_unknown(project)
    project.notified_users
  end
end
