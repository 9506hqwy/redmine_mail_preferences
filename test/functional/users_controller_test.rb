# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class UsersControllerTest < Redmine::ControllerTest
  include Redmine::I18n

  fixtures :users,
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

    u = User.find(1)
    prefs = u.mail_preferences
    if Redmine::VERSION::MAJOR >= 4
      assert_equal 12, prefs.disable_notified_events.length
    else
      assert_equal 11, prefs.disable_notified_events.length
    end
  end
end
