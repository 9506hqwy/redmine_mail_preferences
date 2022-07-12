# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class UsersControllerTest < Redmine::ControllerTest
  include Redmine::I18n

  fixtures :email_addresses,
           :users,
           :user_mail_preferences

  def setup
    @request.session[:user_id] = 1
  end

  def test_edit_get
    get :edit, params: {
      id: 1
    }

    assert_response :success
  end

  def test_update_post
    put :update, params: {
      id: 1,
      user: {
        password: nil,
      },
      settings: {
        notified_events:
        [
          'issue_added',
          'issue_updated',
        ]
      }
    }

    assert_response :redirect

    expect = 7
    expect += 1 if Redmine::Plugin.installed?(:redmine_wiki_extensions)

    u = User.find(1)
    prefs = u.mail_preferences
    assert_equal expect, prefs.disable_notified_events.length
  end
end
