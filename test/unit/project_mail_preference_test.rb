# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class ProjectMailPreferenceTest < ActiveSupport::TestCase
  fixtures :projects,
           :project_mail_preferences

  def test_create
    u = projects(:projects_002)

    p = ProjectMailPreference.new
    p.project = u
    p.disable_notified_events = ['issue_added', 'issue_updated']
    p.save!

    p.reload
    assert_equal u.id, p.project_id
    assert_equal 2, p.disable_notified_events.length
    assert_includes p.disable_notified_events, 'issue_added'
    assert_includes p.disable_notified_events, 'issue_updated'
  end

  def test_update
    u = projects(:projects_005)

    p = u.mail_preferences
    p.disable_notified_events = ['issue_added', 'issue_updated']
    p.save!

    p.reload
    assert_equal u.id, p.project_id
    assert_equal 2, p.disable_notified_events.length
    assert_includes p.disable_notified_events, 'issue_added'
    assert_includes p.disable_notified_events, 'issue_updated'
  end
end
