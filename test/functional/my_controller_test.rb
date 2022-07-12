# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class MyControllerTest < Redmine::ControllerTest
  include Redmine::I18n

  fixtures :email_addresses,
           :users,
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

    if (Redmine::VERSION::ARRAY[0..1] <=> [4, 1]) >= 0
      put :account, params: params
    else
      post :account, params: params
    end

    assert_response :redirect

    expect = 7
    expect += 1 if Redmine::Plugin.installed?(:redmine_wiki_extensions)

    u = User.find(1)
    prefs = u.mail_preferences
    assert_equal expect, prefs.disable_notified_events.length
  end
end
