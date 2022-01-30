# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class MyControllerTest < Redmine::ControllerTest
  include Redmine::I18n

  fixtures :users,
           :user_mail_preferences

  def setup
    @request.session[:user_id] = 1
  end

  def test_account_get
    get :account

    assert_response :success
  end

  def test_account_post
    params = {
      settings: {
        notified_events:
        [
          'issue_added',
          'issue_updated',
        ]
      }
    }

    if Redmine::VERSION::MAJOR >= 4
      put :account, params: params
    else
      post :account, params: params
    end

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