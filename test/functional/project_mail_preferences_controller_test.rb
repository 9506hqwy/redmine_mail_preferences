# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class ProjectMailPreferencesControllerTest < Redmine::ControllerTest
  include Redmine::I18n

  fixtures :member_roles,
           :members,
           :projects,
           :roles,
           :users,
           :project_mail_preferences

  def setup
    @request.session[:user_id] = 2

    role = Role.find(1)
    role.add_permission! :edit_mail_preferences
  end

  def test_update_create
    project = Project.find(1)
    project.enable_module!(:mail_preferences)

    put :update, params: {
      project_id: project.id,
      settings: {
        notified_events:
        [
          'issue_added',
          'issue_updated',
        ]
      }
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/mail_preferences"
    assert_not_nil flash[:notice]
    assert_nil flash[:error]

    expect = 7
    expect += 1 if Redmine::Plugin.installed?(:redmine_wiki_extensions)

    project.reload
    prefs = project.mail_preferences
    assert_equal expect, prefs.disable_notified_events.length
  end

  def test_update_update
    project = Project.find(5)
    project.enable_module!(:mail_preferences)

    put :update, params: {
      project_id: project.id,
      settings: {
        notified_events:
        [
          'issue_added',
          'issue_updated',
        ]
      }
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/mail_preferences"
    assert_not_nil flash[:notice]
    assert_nil flash[:error]

    expect = 7
    expect += 1 if Redmine::Plugin.installed?(:redmine_wiki_extensions)

    project.reload
    prefs = project.mail_preferences
    assert_equal expect, prefs.disable_notified_events.length
  end
end
